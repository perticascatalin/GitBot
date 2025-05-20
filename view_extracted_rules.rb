require 'json'
require 'pathname'

# Directory containing the JSON rule files
dir = Pathname.new('derived_rules')

# Data structures to hold extracted info and counts per user
entries = []
user_counts = Hash.new(0)

total_count = 0

# Iterate through each JSON file in the directory
Dir.glob(dir.join('*.json')).each do |file_path|
  puts "Included file #{file_path}"
  file = File.read(file_path)
  rules = JSON.parse(file)

  rules.each do |rule|
    code_name = rule['code_name']
    user = rule.dig('example', 'user')
    count = rule['count'].to_i

    # Store extracted data
    entries << { code_name: code_name, user: user, count: count }

    # Accumulate counts for ranking
    user_counts[user] += count
    total_count += count
  end
end

# Output extracted entries
puts "| Code Name | User | Count |"
puts "--------------------------------"
entries.each do |e|
  puts "| #{e[:code_name]} | #{e[:user]} | #{e[:count]} |"
end

# Generate and output user ranking
puts "\nUser Ranking by Total Examples"
puts "--------------------------------"
ranking = user_counts.sort_by { |_, total| -total }
 ranking.each_with_index do |(user, total), index|
  puts "#{index + 1}. #{user} - #{total} examples"
end

puts "Total count #{total_count}"
puts "Total entries #{entries.size}"
