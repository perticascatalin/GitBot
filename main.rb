# main.rb
require 'awesome_print'
require 'net/http'
require 'uri'
require 'json'
require 'pry'
require 'date'

require_relative 'repo_utils/github_helper'
require_relative 'repo_utils/view_reviews'

pull_number = 45333
config = JSON.parse(File.read('config.json'))
pull_request = JSON.parse(File.read("data/pull_requests/#{pull_number}.json"))

# # Sample usage
# filtered_data = pull_request.map { |item| item.slice('filename', 'patch') }

# # Build the prompt for the whole diff
# prompt = "Make a summary in natural language of the following code changes:\n\n"
# filtered_data.each do |entry|
#   prompt += "File: #{entry['filename']}\nPatch:\n#{entry['patch']}\n\n"
# end

# # Or just for one file
# prompt = "Review the following file:\n\n"
# prompt += filtered_data.find{ |d| d["filename"] == "app/views/divisions/index/_by_multiple_criteria.html.haml"}["patch"]

# # Build the request
# api_key = config['OPENAI_API_KEY']
# uri = URI('https://api.openai.com/v1/chat/completions')
# headers = {
#   "Content-Type" => "application/json",
#   "Authorization" => "Bearer #{api_key}"
# }
# body = {
#   model: "gpt-4o",
#   messages: [{ role: "user", content: prompt }],
#   max_tokens: 200
# }

# response = Net::HTTP.post(uri, body.to_json, headers)

# puts "Response from ChatGPT:"
# puts JSON.parse(response.body)