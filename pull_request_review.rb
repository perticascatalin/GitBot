require 'awesome_print'
require 'fileutils'
require 'net/http'
require 'date'
require 'json'
require 'uri'
require 'pry'

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

ReviewHelper.save_pull_request_review(pull_number, response)