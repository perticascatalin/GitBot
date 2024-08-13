require 'json'
require 'pry'

reviewed_file = ARGV[0] # file for which you want to see comments

for pg in 1..155 do
	file = File.read("./data/#{pg}.json")
	data = JSON.parse(file)
	for cmt in 0..data.size-1
		fl = data[cmt]["path"]
		if fl == reviewed_file
			puts "#{data[cmt]["body"]}"
		end
	end
end
