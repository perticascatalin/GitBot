require 'json'
require 'pry'
require 'date'
require 'awesome_print'

def print_cmt_data(cmt_data)
  puts cmt_data['path']
  puts '===================================='
  ap cmt_data['body']
  puts '===================================='
  puts cmt_data['user']['login']
  puts DateTime.parse(cmt_data['created_at']).to_date
  puts "\n\n\n"
end

def view_page_reviews(page)
  file = File.read("../data/#{page}.json")
  data = JSON.parse(file)

  for cmt in 0..data.size-1
    print_cmt_data(data[cmt])
  end
end

def view_file_reviews(file_path)
  config_file = File.read('../config.json')
  config = JSON.parse(config_file)
  num_pages = config['pages_of_reviews']

  for page in 1..num_pages do
    file = File.read("../data/#{page}.json")
    data = JSON.parse(file)
    for cmt in 0..data.size-1
      print_cmt_data(data[cmt]) if data[cmt]['path'] == file_path
    end
  end
end

# page = ARGV[0] # page of reviews to look at
# view_page_reviews(page)

# file_path = ARGV[0] # file for which to find reviews
# view_file_reviews(file_path)
