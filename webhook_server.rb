require 'sinatra'
require 'json'
require 'net/http'
require 'uri'
require 'openssl'
require 'pry'

set :port, 5000

file = File.read("./config.json")
config = JSON.parse(file)

SECRET = config["webhook_secret"]

helpers do
  # Verifies the signature of a payload body against a given signature.
  #
  # @param payload_body [String] The body of the payload to be verified.
  # @param signature [String] The signature to compare against.
  # @return [Boolean] Returns true if the signature is valid, false otherwise.
  def verify_signature(payload_body, signature)
    return false if signature.nil?

    sha1 = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), SECRET, payload_body)
    Rack::Utils.secure_compare(sha1, signature)
  end

  def review_commit(url, commit)
    uri = URI.parse(url.sub("github.com", "api.github.com/repos").sub("commit", "commits") + "/comments")
    #   https://api.github.com/repos/OWNER/REPO/commits/COMMIT_SHA/comments \
    # -d '{"body":"Great stuff","path":"file1.txt","position":4,"line":1}

    # Create the HTTP request
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(url)
    request["Accept"] = "application/vnd.github+json"

    files = commit["files"]
    files.each do |file|
      patch = file["patch"]
      filename = file["filename"]
      comment_body = 'Inspecting file ' + filename + ' for potential issues.'

      # Request body
      request.body = {
        body: comment_body,
        path: filename,
        position: patch.to_i.abs
      }.to_json

      # Send the request
      binding.pry
      response = http.request(request)

      # Check and print the response
      if response.code.to_i == 201
        puts "Comment posted successfully!"
        comment = JSON.parse(response.body)
        puts "Comment URL: #{comment['html_url']}"
      else
        puts "Failed to post comment: #{response.code}"
        puts response.body
      end
      
    end


  end

  def analyze_commit(url)
    uri = URI.parse(url.sub("github.com", "api.github.com/repos").sub("commit", "commits"))
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    commit = JSON.parse(response.body)
    review_commit(url, commit)
  end

  # Analyzes the payload of a push event.
  #
  # This method takes a push event payload as input and analyzes each commit in the payload.
  # It retrieves information such as the repository name, commit ID, URL, message, and author.
  # For each commit, it prints a message with the author, commit ID, and message, and then
  # calls the `analyze_commit` method to perform further analysis on the commit.
  #
  # Parameters:
  # @param push: A hash representing the push event payload.
  def analyze_payload(push)
    commits = push["commits"]
    commits.each do |commit|
      repo = push["repository"]["full_name"]
      commit_id = commit["id"]
      url = commit["url"]
      message = commit["message"]
      author = commit["author"]["name"]
      puts "New commit by #{author} with id #{commit_id} and message: #{message}"
      analyze_commit(url)
    end
  end
end

post '/webhook' do
  request.body.rewind
  payload_body = request.body.read
  verify_signature(payload_body, request.env['HTTP_X_HUB_SIGNATURE']) || halt(400, 'Invalid signature')

  push = JSON.parse(payload_body)
  puts "Received payload: #{push.inspect}"

  analyze_payload(push)

  'Webhook received'
end

# Start the server
Sinatra::Application.run!