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

  def analyze_payload(push)
    binding.pry
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