class RepoAnalysis
  def initialize(data_directory)
    @data_directory = data_directory
  end

  def view_page_reviews(page)
    file = read_data_file(page)
    data = JSON.parse(file)

    data.each do |cmt|
      print_cmt_data(cmt)
    end
  end

  def view_file_reviews(file_path)
    num_pages = total_pages

    (1..num_pages).each do |page|
      file = read_data_file(page)
      data = JSON.parse(file)
      data.each do |cmt|
        print_cmt_data(cmt) if cmt['path'] == file_path
      end
    end
  end

  def pull_request_data(pull_number)
    file = read_data_file(pull_number)
    data = JSON.parse(file)
    data.map { |item| item.slice('filename', 'patch') }
  end

  def pull_request_files(pull_number)
    file = read_data_file(pull_number)
    data = JSON.parse(file)
    data.map { |item| item['filename'] }
  end

  def analyze_reviews
    user_count = Hash.new(0)
    file_count = Hash.new(0)
    file_user_count = Hash.new { |hash, key| hash[key] = Hash.new(0) }

    total_pages.times do |page|
      page += 1 # pages start from 1
      file = read_data_file(page)
      data = JSON.parse(file)

      if data.is_a?(Array)
        data.each do |cmt|
          user = cmt['user']['login']
          user_count[user] += 1

          fl = cmt['path']
          file_count[fl] += 1

          file_user_count[fl][user] += 1
        end
      else
        puts "Invalid data format on page #{page}"
      end
    end

    sorted_user_count = user_count.sort_by { |_, value| -value }.to_h
    sorted_file_count = file_count.sort_by { |_, value| -value }.to_h

    file_user_count_sorted = file_user_count
      .sort_by { |_, users| -users.values.sum }
      .map { |file, users| [file, users.sort_by { |_, count| -count }.to_h] }
      .to_h

    aggregated_reviews = aggregate_reviews(file_user_count_sorted)

    {
      user_count: sorted_user_count,
      file_count: sorted_file_count,
      file_user_count: file_user_count_sorted,
      aggregated_reviews: aggregated_reviews
    }
  end

  private

  def total_pages
    Dir.glob(File.join(@data_directory, '*.json')).map do |file|
      File.basename(file, '.json').to_i
    end.max
  end

  def read_data_file(id)
    file_path = File.join(@data_directory, "#{id}.json")
    raise "File not found: #{file_path}" unless File.exist?(file_path)

    File.read(file_path)
  end

  def print_cmt_data(cmt_data)
    puts cmt_data['path']
    puts '===================================='
    ap cmt_data['body']
    puts '===================================='
    puts cmt_data['user']['login']
    puts DateTime.parse(cmt_data['created_at']).to_date
    puts "\n\n\n"
  end

  def aggregate_reviews(file_reviews)
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

    aggregated_reviews.transform_values do |user_reviews|
      user_reviews.sort_by { |_, count| -count }.to_h
    end
  end
end