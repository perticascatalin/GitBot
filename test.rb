require 'awesome_print'
require 'net/http'
require 'uri'
require 'json'
require 'pry'
require 'date'

require_relative 'repo_utils/github_helper'
require_relative 'repo_utils/repo_analysis'
require_relative 'repo_utils/review_helper'

# config = JSON.parse(File.read('config.json'))

# github_helper = GitHubHelper.new('config.json')
# pull_number = 45142
# github_helper.download_pull_request(pull_number)

github_helper = GitHubHelper.new('test_config.json')

