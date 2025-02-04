require 'awesome_print'
require 'fileutils'
require 'truncate'
require 'net/http'
require 'date'
require 'json'
require 'uri'
require 'pry'

require_relative 'repo_utils/github_helper'
require_relative 'repo_utils/repo_analysis'
require_relative 'repo_utils/review_helper'


page_number = 182

prompt = ReviewHelper.page_reviews_extract_rules_prompt(page_number)
response = ReviewHelper.get_prompt_response('config.json', page_number, prompt)
ReviewHelper.save_derived_rules(page_number, response)



