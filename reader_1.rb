require 'json'
require 'pry'

pg = ARGV[0] # page you want to read

file = File.read("./data/#{pg}.json")
data = JSON.parse(file)

for cmt in 0..data.size-1
	puts "#{data[cmt]["body"]} - #{data[cmt]["user"]["login"]} - #{data[cmt]["created_at"]}"
end

for cmt in 0..data.size-1
	puts "#{data[cmt]["path"]}"
end