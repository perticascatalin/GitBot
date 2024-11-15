# main.rb
require 'awesome_print'
require 'net/http'
require 'uri'
require 'json'
require 'pry'
require 'date'

require_relative 'repo_utils/github_helper'
require_relative 'repo_utils/repo_analysis'

config = JSON.parse(File.read('config.json'))

pull_number = 45333
sample_file = "app/views/divisions/index/_by_multiple_criteria.html.haml"

repo_analysis = RepoAnalysis.new('data/pull_requests')
pull_request = repo_analysis.pull_request_data(pull_number)


# Build the prompt for the whole diff
prompt = "Make a summary in natural language of the following code changes:\n\n"
pull_request.each do |entry|
  prompt += "File: #{entry['filename']}\nPatch:\n#{entry['patch']}\n\n"
end

# Or just for one file
prompt = "Review the following file:\n\n"
prompt += pull_request.find{ |d| d["filename"] == sample_file}["patch"]

# Build the request
api_key = config['OPENAI_API_KEY']
uri = URI('https://api.openai.com/v1/chat/completions')
headers = {
  "Content-Type" => "application/json",
  "Authorization" => "Bearer #{api_key}"
}
body = {
  model: "gpt-4o",
  messages: [{ role: "user", content: prompt }],
  max_tokens: 200
}

response = Net::HTTP.post(uri, body.to_json, headers)

puts "Response from ChatGPT:"
puts JSON.parse(response.body)