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
AUTH = config["github_token"]


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

  def call_ai_services(hunks)
    # Call AI services

    # Define the URL of your Python server
    uri = URI.parse('http://localhost:8000')

    # Create the HTTP request
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 600 # 600 seconds for open timeout
    http.read_timeout = 600 # 600 seconds for read timeout
    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"

    # Define the request body
    body = {}
    hunks.each_with_index{|h, index| body[index] = h}
    request.body = body.to_json

    # Send the request and get the response
    response = http.request(request)

    # Print the response body
    puts response.body

    comments = JSON.parse(response.body)
    return JSON.parse(comments['received_data']).values
  end  

  # Public: Posts review comments on a commit.
  #
  # url    - The URL of the commit to review.
  # commit - The commit object containing information about the files to review.
  def review_commit(url, commit)
    uri = URI.parse(url.sub("github.com", "api.github.com/repos").sub("commit", "commits") + "/comments")

    # Create the HTTP request
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri)
    request["Accept"] = "application/vnd.github+json"
    request["X-Github-Api-Version"] = "2022-11-28"
    request["Authorization"] = AUTH
    files = commit["files"]
    hunks_in_all_files = []
    files.each do |file|
      patch = file["patch"]
      filename = file["filename"]
      comment_body = 'Inspecting file ' + filename + ' for potential issues.'
      # Line in the file where the first hunk begins
      start_position = patch.lines.first.split(/[^\d]/).select{|s| !s.empty?}.first.to_i
      # However, there can be several hunks in a file
      num_hunks = patch.lines.select{|l| l.start_with?("@@")}.count
      # Need to remove end of file marker (edge case for comment at the end of the file)
      eof = patch.lines.any?{|l| l.start_with?("\\ No newline at end of file")} ? 1 : 0
      # This will place the comment at the end of the last hunk)
      position = patch.lines.count - eof - 1

      # Split into hunks
      hunks = []
      current_hunk = ""
      patch.lines.each_with_index do |line, index|
        if line.start_with?("@@")
          hunks << current_hunk
          current_hunk = ""
        else
          current_hunk += line
        end
      end
      hunks << current_hunk

      empty = hunks.shift
      # hunks_in_all_files += hunks
      comments = call_ai_services(hunks)
      start_index = 0

      # One review per hunk, add a comment after first line of each hunk
      patch.lines.each_with_index do |line, index|
        if line.start_with?("@@")

          position = index + 1
          # Request body
          request.body = {
            # body: comment_body,
            body: comments[start_index],
            commit_id: commit["sha"],
            path: filename,
            position: position
          }.to_json
          start_index += 1

          # Send the request
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
    end
  end

  # Analyzes a commit by making a GET request to the GitHub API and reviewing the commit.
  #
  # @param url [String] The URL of the commit.
  # @return [void]
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
  binding.pry
  puts "Received payload: #{push.inspect}"

  analyze_payload(push)

  'Webhook received'
end

# Start the server
Sinatra::Application.run!