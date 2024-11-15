# main.rb
require 'net/http'
require 'uri'
require 'json'
require 'pry'

require_relative 'repo_utils/get_reviews'

start_page = 178
end_page = 178
git_helper = GitHubHelper.new('config.json')
git_helper.download_comments(start_page, end_page)
git_helper.download_pull_request(45333)
