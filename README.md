# GitBot

## Webhook Server

```ruby
# Start service for automatic reviews
ngrok http 5000
ruby webhook_server.rb
```

## Repository Utils

### GitHub Helper

Uses the Git API to do the following:

- Download the review comments for a repository
- Download the diff of a given pull request

Setup steps:

- Create config.json file
- Set the following fields:
  - "repo_owner" - repository owner
  - "repo_name" - repository name
  - "github_token" - needed if the repository is private

```ruby
require_relative 'repo_utils/github_helper'

start_page = 1
end_page = 10
pull_number = 100
github_helper = GitHubHelper.new('config.json')
github_helper.download_comments(start_page, end_page)
github_helper.download_pull_request(pull_number)
```

### Repo Analysis

```ruby
require_relative 'repo_utils/repo_analysis'

page = 1
filepath = 'app/lib/x.rb'
repo_analysis = RepoAnalysis.new('data/reviews')
repo_analysis.view_page_reviews(page)
repo_analysis.view_file_reviews(filepath)
analysis = repo_analysis.analyze_reviews
analysis[:user_count]
analysis[:file_count]
analysis[:file_user_count]
analysis[:aggregated_reviews]

pull_number = 100
repo_analysis = RepoAnalysis.new('data/pull_requests')
pull_request = repo_analysis.pull_request_data(pull_number)
files = repo_analysis.pull_request_files(pull_number)
```