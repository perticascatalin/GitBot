require 'net/http'
require 'uri'
require 'pry'
require 'json'

file = File.read('../config.json')
$config = JSON.parse(file)
$repo_owner = $config['repo_owner']
$repo_name = $config['repo_name']

def page_request(pg)
  per_page = 100

  uri = URI.parse("https://api.github.com/repos/#{$repo_owner}/#{$repo_name}/pulls/comments?per_page=#{per_page}&page=#{pg}&sort='created_at'&direction='desc'")
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

  File.open("../data/#{pg}.json", 'w') do |f|
    f.write(data.to_json)
  end
end

for pg in 1..$config['pages_of_reviews'] do
  page_request(pg)
end