require 'awesome_print'
require 'net/http'
require 'uri'
require 'json'
require 'pry'
require 'date'

require_relative 'repo_utils/github_helper'
require_relative 'repo_utils/repo_analysis'
require_relative 'repo_utils/review_helper'

github_helper = GitHubHelper.new('config.json')
repo_analysis = RepoAnalysis.new('data/pull_requests')

pull_number = 45471
run_number = 1
file_sha = repo_analysis.pull_request_file_sha(pull_number)
github_helper.post_comments_for_review(pull_number, run_number, file_sha)