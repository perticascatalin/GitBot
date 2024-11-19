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

pull_number = 45471
# github_helper = GitHubHelper.new('config.json')
# github_helper.download_pull_request(pull_number)

repo_analysis = RepoAnalysis.new('data/pull_requests')
pull_request = repo_analysis.pull_request_data(pull_number)
filenames = repo_analysis.pull_request_files(pull_number)
rules = JSON.parse(File.read('checklist.json'))

results = ReviewHelper.find_applicable_rules(filenames, rules)
prompt = ReviewHelper.pull_request_review_prompt(pull_request, results, rules)
response = ReviewHelper.get_pull_request_review_response('config.json', pull_number, prompt)

puts "Response from ChatGPT:"
output = JSON.parse(response.body)
puts output["choices"][0]["message"]["content"]

binding.pry