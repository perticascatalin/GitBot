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
      prompt += "File: #{entry['filename']}\nPatch:\n#{entry['patch']}\n\n"
    end

    prompt += "Note: Each file patch only shows the code area where there were changes, indicating the lines, the length of the code hunk and the method if applicable.\n"
    prompt += "Note: Added code is marked with '+', while removed code is markes with a '-'. Parts of the file might be missing in the patch.\n\n"

    prompt += "For each file, only check the rules indicated by the following json (filename - array of codenames):\n\n"
    prompt += results.to_s

    prompt += "The rules are described in the following json (codename - explanation):\n\n"
    prompt += rules.map{|rule| rule.slice('code_name', 'explanation')}.to_s

    prompt += "Output a json with filenames as keys indicating which of the applicable rules is not adhered to, can be none or several.\n" 
    prompt += "For this, Use the field not_adhered_to (array of {codename: rule, motivation: why?})\n"
    prompt += "If one of the rule is not adhered to, briefly motivate how / why and specify the code block breaking the rule.\n"
    prompt += "At the end, write a summary of the findings and highlight the most important issues in the code if there are any."

    prompt
  end
end
