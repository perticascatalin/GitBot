require 'json'
require 'pry'
require 'date'
require 'awesome_print'

pg = ARGV[0] # page of reviews to look at

file = File.read("../data/#{pg}.json")
data = JSON.parse(file)

for cmt in 0..data.size-1
  puts data[cmt]['path']
  puts '===================================='
  ap data[cmt]['body']
  puts '===================================='
  puts data[cmt]['user']['login']
  puts DateTime.parse(data[cmt]['created_at']).to_date
  puts "\n\n\n"
end