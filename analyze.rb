require 'json'
require 'pry'

user_count = {}
file_count = {}

file = File.read("./config.json")
config = JSON.parse(file)

PAGES = config["pages_of_reviews"]

for pg in 1..PAGES do
	file = File.read("./data/#{pg}.json")
	data = JSON.parse(file)
	for cmt in 0..data.size-1
		user = data[cmt]["user"]["login"]
		if user_count[user].nil?
			user_count[user] = 1
		else
			user_count[user] += 1
		end
		fl = data[cmt]["path"]
		if file_count[fl].nil?
			file_count[fl] = 1
		else
			file_count[fl] += 1
		end
	end
end

user_count = user_count.sort_by {|key, value| -value}.to_h
file_count = file_count.sort_by {|key, value| -value}.to_h

binding.pry