require 'net/http'
require 'uri'
require 'json'

file = File.read('../config.json')
$config = JSON.parse(file)
$repo_owner = $config['repo_owner']
$repo_name = $config['repo_name']

def pull_request(pull_number)
  uri = URI.parse("https://api.github.com/repos/#{$repo_owner}/#{$repo_name}/pulls/#{pull_number}/files")
  request = Net::HTTP::Get.new(uri)
  request['Accept'] = 'application/vnd.github+json'
  request['Authorization'] = $config['github_token']
  request['X-Github-Api-Version'] = '2022-11-28'

  req_options = {
    use_ssl: uri.scheme == 'https'
  }

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end

  data = JSON.parse(response.body)
end

# Sample usage
data = pull_request(45333)
filtered_data = data.map { |item| item.slice("filename", "patch") }

# Build the prompt for the whole diff
prompt = "Make a summary in natural language of the following code changes:\n\n"
filtered_data.each do |entry|
  prompt += "File: #{entry['filename']}\nPatch:\n#{entry['patch']}\n\n"
end

# Or just for one file
prompt = "Review the following file:\n\n"
prompt += filtered_data.find{ |d| d["filename"] == "app/views/divisions/index/_by_multiple_criteria.html.haml"}["patch"]

# Build the request
api_key = $config['OPENAI_API_KEY']
uri = URI('https://api.openai.com/v1/chat/completions')
headers = {
  "Content-Type" => "application/json",
  "Authorization" => "Bearer #{api_key}"
}
body = {
  model: "gpt-4o",
  messages: [{ role: "user", content: prompt }],
  max_tokens: 200
}

response = Net::HTTP.post(uri, body.to_json, headers)

puts "Response from ChatGPT:"
puts JSON.parse(response.body)
