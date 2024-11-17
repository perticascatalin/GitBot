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

pull_number = 45333
sample_file = "app/views/divisions/index/_by_multiple_criteria.html.haml"

repo_analysis = RepoAnalysis.new('data/pull_requests')
pull_request = repo_analysis.pull_request_data(pull_number)
filenames = repo_analysis.pull_request_files(pull_number)
rules = JSON.parse(File.read('checklist2.json'))
results = ReviewHelper.find_applicable_rules(filenames, rules)

# # Build the prompt for the whole diff
# prompt = "Make a summary in natural language of the following code changes:\n\n"
# pull_request.each do |entry|
#   prompt += "File: #{entry['filename']}\nPatch:\n#{entry['patch']}\n\n"
# end

# # Or just for one file
# prompt = "Review the following file:\n\n"
# prompt += pull_request.find{ |d| d["filename"] == sample_file}["patch"]


prompt = "Review the following pull request patch:\n\n"
pull_request.each do |entry|
  prompt += "File: #{entry['filename']}\nPatch:\n#{entry['patch']}\n\n"
end
prompt += "For each file, only check the rules indicated by the following json (filename - array of codenames):\n\n"
prompt += results.to_s
prompt += "The rules are described in the following json (codename - explanation):\n\n"
prompt += rules.to_s
prompt += "Output a json with filenames as keys indicating which of the applicable rules is not adhered to, can be none or several." 
prompt += "For this, Use the field not_adhered_to (array of {codename: rule, motivation: why?}) If one of the rule is not adhered to, briefly motivate how / why and specify the code line or block breaking the rule."
prompt += "At the end, write a summary of the findings and highlight the most important issues in the code if there are any."

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
  max_completion_tokens: 20000
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