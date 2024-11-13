require 'json'
require 'pry'

user_count = {}
file_count = {}
file_user_count = {}

file = File.read('../config.json')
config = JSON.parse(file)

num_pages = config['pages_of_reviews']

for page in 1..num_pages do
  file = File.read("../data/#{page}.json")
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
      if file_user_count[fl].nil?
        file_user_count[fl] = {}
      end
      if file_user_count[fl][user].nil?
        file_user_count[fl][user] = 1
      else
        file_user_count[fl][user] += 1
      end
    end
  else
    puts page
  end
end

user_count = user_count.sort_by { |key, value| -value }.to_h
file_count = file_count.sort_by { |key, value| -value }.to_h

file_user_count = file_user_count
  .sort_by { |file, users| -users.values.sum }
  .map do |file, users|
    [file, users.sort_by { |user, count| -count }.to_h]
  end
  .to_h

file_reviews = file_user_count
aggregated_reviews = Hash.new { |hash, key| hash[key] = Hash.new(0) }
file_reviews.each do |path, users|
  folders = path.split('/')
  folders.each_index do |i|
    folder_path = folders[0..i].join('/') + '/'
    users.each do |user, count|
      aggregated_reviews[folder_path][user] += count
    end
  end
end

sorted_aggregated_reviews = aggregated_reviews.transform_values do |user_reviews|
  user_reviews.sort_by { |user, count| -count }.to_h
end

binding.pry