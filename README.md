# GitBot

## Repository Utils

### GitHub Helper

Setup steps:

- Create config.json file
- Set the following fields:
  - "repo_owner" - repository owner
  - "repo_name" - repository name
  - "github_token" - needed if the repository is private

Uses the Git API to do the following:

- Download the review comments for a repository
- Download the diff of a given pull request

```ruby
require_relative 'repo_utils/github_helper'

start_page = 1
end_page = 10
pull_number = 100
github_helper = GitHubHelper.new('config.json')
github_helper.download_comments(start_page, end_page)
github_helper.download_pull_request(pull_number)
```

Additionally, the Git API can be used to post new review comments using the method `post_comment` for one comment or `post_comments_for_review` for multiple comments saved locally under the format to be documented in the Review Helper section.

To post a single comment, the input parameters are the pull request number, the filename for which to post the comment, the comment and an SHA which can be retrieved when downloading the pull request.

### Repo Analysis

Extracts data for analysis:

- Review comments
  - View all reviews from a given page
  - View all reviews for a given file
  - Analysis
    - Number of comments per user
    - Number of comments per file
    - Number of comments per user and file
- Pull Request diffs
  - Array of hashes with "filename" and "patch" keys

```ruby
require_relative 'repo_utils/repo_analysis'

page = 1
filepath = 'app/lib/x.rb'
repo_analysis = RepoAnalysis.new('data/reviews', 'excluded.json')
repo_analysis.view_page_reviews(page)
repo_analysis.view_file_reviews(filepath)
analysis = repo_analysis.analyze_reviews
analysis[:user_count]
analysis[:file_count]
analysis[:file_user_count]
analysis[:aggregated_reviews]

pull_number = 100
repo_analysis = RepoAnalysis.new('data/pull_requests', 'excluded.json')
pull_request = repo_analysis.pull_request_data(pull_number)
files = repo_analysis.pull_request_files(pull_number)
```

### Review Helper

TODO: sample usage

Methods:

#### find_applicable_rules

The rules for reviewing a pull request can be defined in the file `checklist.json` which contains an array of hashes in the format:

```json
  {
    "code_name": "Clean and Readable Views Code",
    "explanation": "Is the code clean and readable? If applicable, suggest avoiding deep nesting and grouping related elements. Break down complex views into smaller reusable partials.",
    "rule": {
      "file_patterns": ["**/*.html.haml"],
      "exclude_patterns": [],
      "description": "Applies to .html.haml template files."
    }
  }
```

The method **find_applicable_rules** looks at a pull request diff and determines which rules are applicable for the files based on `file_patterns` and `exclude_patterns`.

#### pull_request_review_prompt

This method creates a prompt for an automated code review using the pull request data and the applicable rules.

#### get_pull_request_review_response

This method creates a request for an automated code review and sends it to the OpenAI API.

#### save_pull_request_review

This method saves the pull request review locally.

## Webhook Server

```ruby
# Start service for automatic reviews
ngrok http 5000
ruby webhook_server.rb
```