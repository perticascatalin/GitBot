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
end
