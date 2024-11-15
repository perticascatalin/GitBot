# main.rb
require 'net/http'
require 'uri'
require 'json'
require 'pry'

require_relative 'repo_utils/github_helper'

start_page = 178
end_page = 178
github_helper = GitHubHelper.new('config.json')
github_helper.download_comments(start_page, end_page)
github_helper.download_pull_request(45333)
