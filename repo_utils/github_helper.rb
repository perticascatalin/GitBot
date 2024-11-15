class GitHubHelper
  def initialize(config_path)
    @config = load_config(config_path)
    @repo_owner = @config['repo_owner']
    @repo_name = @config['repo_name']
    @github_token = @config['github_token']
  end

  def download_comments(start_page, end_page)
    (start_page..end_page).each do |page|
      puts "Downloading reviews page #{page}"
      reviews_page_request(page)
    end
  end

  def download_pull_request(pull_number)
    puts "Downloading pull request #{pull_number}"
    pull_request_request(pull_number)
  end

  private

  def load_config(path)
    file = File.read(path)
    JSON.parse(file)
  end

  def reviews_page_request(page)
    per_page = 100
    uri = URI.parse("https://api.github.com/repos/#{@repo_owner}/#{@repo_name}/pulls/comments?per_page=#{per_page}&page=#{page}")
    request = Net::HTTP::Get.new(uri)
    request['Accept'] = 'application/vnd.github+json'
    request['Authorization'] = @github_token
    request['X-Github-Api-Version'] = '2022-11-28'

    req_options = {
      use_ssl: uri.scheme == 'https'
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    data = JSON.parse(response.body)
    save_to_file('reviews', page, data)
  end

  def pull_request_request(pull_number)
    uri = URI.parse("https://api.github.com/repos/#{@repo_owner}/#{@repo_name}/pulls/#{pull_number}/files")
    request = Net::HTTP::Get.new(uri)
    request['Accept'] = 'application/vnd.github+json'
    request['Authorization'] = @config['github_token']
    request['X-Github-Api-Version'] = '2022-11-28'

    req_options = {
      use_ssl: uri.scheme == 'https'
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    data = JSON.parse(response.body)
    save_to_file('pull_requests', pull_number, data)
  end

  def save_to_file(subfolder, id, data)
    File.open("data/#{subfolder}/#{id}.json", 'w') do |f|
      f.write(data.to_json)
    end
  end
end