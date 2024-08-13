require 'net/http'
require 'uri'
require 'pry'
require 'json'


uri = URI.parse("https://api.github.com/repos/ruby/ruby/pulls/comments?per_page=2&page=1&sort='created_at'&direction='desc'")
request = Net::HTTP::Get.new(uri)
request["Accept"] = "application/vnd.github+json"
request["X-Github-Api-Version"] = "2022-11-28"

req_options = {
  use_ssl: uri.scheme == "https",
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end

data = JSON.parse(response.body)

binding.pry

# response.code
# response.body