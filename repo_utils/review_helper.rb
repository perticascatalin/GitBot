module ReviewHelper
  def self.find_applicable_rules(filenames, rules)
    results = {}
    filenames.each do |filename|
      applicable_rules = []
      rules.each do |rule|
        file_patterns = rule['rule']['file_patterns'] || []
        exclude_patterns = rule['rule']['exclude_patterns'] || []
        applies = file_patterns.any? do |pattern|
          File.fnmatch(pattern, filename, File::FNM_PATHNAME | File::FNM_EXTGLOB)
        end

        if applies
          excluded = exclude_patterns && exclude_patterns.any? do |pattern|
            File.fnmatch(pattern, filename, File::FNM_PATHNAME | File::FNM_EXTGLOB)
          end
          applicable_rules << rule['code_name'] unless excluded
        end
      end

      results[filename] = applicable_rules unless applicable_rules.empty?
    end
    results
  end

  def self.pull_request_review_prompt(pull_request, results, rules)
    prompt = "Review the following pull request patch:\n\n"
    pull_request.each do |entry|
      prompt += "File: #{entry['filename']}\nPatch:\n#{entry['patch']}\n\n" if results[entry['filename']]
    end

    prompt += "Note: Each file patch only shows the code area where there were changes, indicating the lines, the length of the code hunk and the method if applicable.\n"
    prompt += "Note: Added code is marked with '+', while removed code is markes with a '-'. Parts of the file might be missing in the patch.\n\n"

    prompt += "For each file, only check the rules indicated by the following json (filename - array of codenames):\n\n"
    prompt += results.to_s

    prompt += "The rules are described in the following json (codename - explanation):\n\n"
    prompt += rules.map{|rule| rule.slice('code_name', 'explanation')}.to_s

    prompt += "Output a json with filenames as keys indicating which of the applicable rules is not adhered to, can be none or several.\n" 
    prompt += "For this, Use the field not_adhered_to (array of {codename: rule, motivation: why?, code_block: code in file patch where the problem was identified, approved_by_manager: always set to 'TBD', this will be edited by human})\n"
    prompt += "If one of the rule is not adhered to, briefly motivate how / why and specify the code block breaking the rule.\n"
    prompt += "At the end, write a summary of the findings and highlight the most important issues in the code if there are any."

    prompt
  end

  def self.page_reviews_extract_rules_prompt(page_number)
    prompt = "Given the following code review comments and diff hunks, extract a set of coding rules following this JSON format and include the pull request where the comments in the extracted examples were left as additional fields in the json:\n\n"
    prompt += "{\n  \"code_name\": \"<short descriptive name>\",\n  \"explanation\": \"<detailed explanation of the rule, including why it matters>\",\n  \"rule\": {\n    \"file_patterns\": [\"<glob pattern(s)>\"],\n    \"description\": \"<description of where or how the rule applies>\"\n  },\n  \"example\": {\n    \"diff_hunk\": \"<exact diff hunk showing the issue>\",\n    \"comment\": \"<the review comment or suggestion>\",\n    \"user\": \"<username of the reviewer>\",\n    \"date\": \"<date of the review>\"\n  },\n  \"count\": <number of times this rule was encountered>\n}\n\n"
    prompt += "The rules should be derived from actionable, clear suggestions that improve code quality, maintainability, security, or performance. Consider comments with specific change recommendations, comments highlighting recurring issues, and ones that include detailed diff hunks as the most relevant. Process the provided review comments and output a JSON list of the extracted rules."
    prompt += JSON.parse(File.read(File.join("data/reviews/","#{page_number}.json"))).to_s
    return prompt
  end

  def self.get_prompt_response(config_path, prompt_id, prompt)
    puts "Reviewing prompt with id #{prompt_id}"
    config = JSON.parse(File.read(config_path))
    api_key = config['OPENAI_API_KEY2']
    uri = URI('https://api.openai.com/v1/chat/completions')
    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{api_key}"
    }
    body = {
      model: "o1-preview",
      max_completion_tokens: 30000,
      # model: "gpt-4o",
      # max_tokens: 10000,
      messages: [{ role: "user", content: prompt.truncate(100000) }]
    }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 300
    http.read_timeout = 300

    request = Net::HTTP::Post.new(uri.request_uri, headers)
    request.body = body.to_json
    response = http.request(request)
    JSON.parse(response.body)["choices"][0]["message"]["content"]
  end

  def self.save_pull_request_review(pull_number, response)
    dir_path = File.join('results', pull_number.to_s)
    FileUtils.mkdir_p(dir_path) unless Dir.exist?(dir_path)

    if match = response.match(/```json\n(.*?)```/m)
      json_content = match[1]
      md_content = response.sub(match[0], '').strip

      existing_files = Dir.entries(dir_path).select { |f| f =~ /^run_(\d+)\.(json|md)$/ }
      numbers = existing_files.map { |f| f[/run_(\d+)\./, 1].to_i }
      next_number = (numbers.max || 0) + 1

      json_file_path = File.join(dir_path, "run_#{next_number}.json")
      md_file_path = File.join(dir_path, "run_#{next_number}.md")

      File.open(json_file_path, "w") { |file| file.write(json_content) }
      File.open(md_file_path, "w") { |file| file.write(md_content) }
    else
      puts "No JSON content found"
    end
  end

  def self.save_derived_rules(page_number, response)
    dir_path = 'derived_rules'
    FileUtils.mkdir_p(dir_path) unless Dir.exist?(dir_path)
    json_file_path = File.join(dir_path, "#{page_number}.json")
    File.open(json_file_path, "w") { |file| file.write(response) }
  end
end