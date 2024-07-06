require 'sinatra'
require 'json'
require 'openssl'
require 'pry'

set :port, 5000

file = File.read("./secrets.json")
secrets = JSON.parse(file)

SECRET = secrets["webhook_secret"]

helpers do
  def verify_signature(payload_body, signature)
    return false if signature.nil?

    sha1 = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), SECRET, payload_body)
    Rack::Utils.secure_compare(sha1, signature)
  end
end

post '/webhook' do
  request.body.rewind
  payload_body = request.body.read
  verify_signature(payload_body, request.env['HTTP_X_HUB_SIGNATURE']) || halt(400, 'Invalid signature')

  push = JSON.parse(payload_body)
  puts "Received payload: #{push.inspect}"

  'Webhook received'
end

# Start the server
Sinatra::Application.run!