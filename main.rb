# main.rb
require 'awesome_print'
require 'net/http'
require 'uri'
require 'json'
require 'pry'
require 'date'

require_relative 'repo_utils/github_helper'
require_relative 'repo_utils/repo_analysis'
require_relative 'repo_utils/review_helper'

config = JSON.parse(File.read('config.json'))
pull_number = 45142

repo_analysis = RepoAnalysis.new('data/pull_requests')
pull_request = repo_analysis.pull_request_data(pull_number)
filenames = repo_analysis.pull_request_files(pull_number)
rules = JSON.parse(File.read('checklist.json'))
results = ReviewHelper.find_applicable_rules(filenames, rules)
prompt = ReviewHelper.pull_request_review_prompt(pull_request, results, rules)

# body = {
#   model: "gpt-4o",
#   messages: [{ role: "user", content: prompt }],
#   max_tokens: 10000
# }

# Build the request
api_key = config['OPENAI_API_KEY2']
uri = URI('https://api.openai.com/v1/chat/completions')
headers = {
  "Content-Type" => "application/json",
  "Authorization" => "Bearer #{api_key}"
}
body = {
  model: "o1-preview",
  messages: [{ role: "user", content: prompt }],
  max_completion_tokens: 30000
}

# Create a new Net::HTTP object
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true  # Enable SSL/TLS

# Set the timeouts (in seconds)
http.open_timeout = 300    # Time to wait for the connection to open
http.read_timeout = 300    # Time to wait for data to be read

# Build the POST request
request = Net::HTTP::Post.new(uri.request_uri, headers)
request.body = body.to_json

# Send the request
response = http.request(request)

puts "Response from ChatGPT:"
output = JSON.parse(response.body)
puts output["choices"][0]["message"]["content"]

binding.pry