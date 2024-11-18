require 'awesome_print'
require 'net/http'
require 'uri'
require 'json'
require 'pry'
require 'date'

require_relative 'repo_utils/github_helper'
require_relative 'repo_utils/repo_analysis'
require_relative 'repo_utils/review_helper'

# pull_number = 45142
# github_helper = GitHubHelper.new('config.json')
# github_helper.download_pull_request(pull_number)

pull_number = 2
github_helper = GitHubHelper.new('test_config.json')
github_helper.download_pull_request(pull_number)
filenames = ["repo_utils/github_helper.rb", "repo_utils/repo_analysis.rb", "test.rb"]

repo_analysis = RepoAnalysis.new('data/pull_requests')
pull_request = repo_analysis.pull_request_data(pull_number)
file_sha = repo_analysis.pull_request_file_sha(pull_number)

filenames.each_with_index do |filename, index|
  comment = "Comment #{index + 1}"
  sha = file_sha[filename]
  github_helper.post_comment(pull_number, sha, filename, comment)
end