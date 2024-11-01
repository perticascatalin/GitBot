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

def view_page_reviews(pg)
  file = File.read("./data/#{pg}.json")
  data = JSON.parse(file)

  for cmt in 0..data.size-1
    print_cmt_data(data[cmt])
  end
end

def view_file_reviews(reviewed_file)
  config_file = File.read('./config.json')
  config = JSON.parse(config_file)
  num_pages = config['pages_of_reviews']

  for pg in 1..num_pages do
    file = File.read("./data/#{pg}.json")
    data = JSON.parse(file)
    for cmt in 0..data.size-1
      fl = data[cmt]['path']
      print_cmt_data(data[cmt]) if fl == reviewed_file
    end
  end
end

pg = ARGV[0] # page of reviews to look at
view_page_reviews(pg)

# reviewed_file = ARGV[0] # file for which to find reviews
# view_file_reviews(reviewed_file)
