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
github_helper = GitHubHelper.new('config.json')
repo_analysis = RepoAnalysis.new('data/pull_requests')
pull_request = repo_analysis.pull_request_data(pull_number)
file_sha = repo_analysis.pull_request_file_sha(pull_number)

reviews = JSON.parse(File.read('sample_answer.json'))
reviews.each do |filename, review|
  comments = review['not_adhered_to']
  sha = file_sha[filename]
  # puts filename
  # puts "sha #{sha}"
  comments.each do |comment|
    codename = comment['codename']
    motivation = comment['motivation']
    code_block = comment['code_block']
    # puts codename
    # puts motivation
    # puts code_block

    comment_body = "**#{codename}**\n\n"
    comment_body += "#{motivation}\n\n"
    comment_body += "```\n"
    comment_body += (code_block + "\n")
    comment_body += "```\n"

    # puts comment_body
    github_helper.post_comment(pull_number, sha, filename, comment_body)
  end
end