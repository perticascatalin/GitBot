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