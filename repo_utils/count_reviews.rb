require 'json'
require 'pry'

user_count = {}
file_count = {}

file = File.read('./config.json')
config = JSON.parse(file)

num_pages = config['pages_of_reviews']

for page in 1..num_pages do
  file = File.read("./data/#{page}.json")
  data = JSON.parse(file)
  if data.class == Array
    for cmt in 0..data.size-1
      user = data[cmt]['user']['login']
      if user_count[user].nil?
        user_count[user] = 1
      else
        user_count[user] += 1
      end
      fl = data[cmt]['path']
      if file_count[fl].nil?
        file_count[fl] = 1
      else
        file_count[fl] += 1
      end
    end
  else
    puts page
  end
end

user_count = user_count.sort_by {|key, value| -value}.to_h
file_count = file_count.sort_by {|key, value| -value}.to_h