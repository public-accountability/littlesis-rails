# frozen_string_literal: true

module ExternalDataset
  module CommcandExtractor
    def self.run(filepath)
      errors = 0
      Utility.zip_entry_each_line(zip: filepath, file: 'COMMCAND.txt') do |line|
        parsed_line = parse_line(line.encode('ASCII', invalid: :replace, undef: :replace, replace: ''))
        if parsed_line == :error
          Rails.logger.warn "[CommcandExtractor] Could not import line\n    #{line.strip}\n"
          errors += 1
        else
          yield parsed_line
        end
      end
      Rails.logger.warn "[NYSFilerImporter] Skipped #{errors} lines with errors."
    end

    private_class_method def self.parse_line(line, attempt: 0)
      return :error if attempt == 2

      CSV.parse_line(line)
    rescue CSV::MalformedCSVError
      # Try to correct some middle names in quotes that are not escaped (example: 'Foo "Middle" Bar')
      # and other misquoting errors...
      if (match = /[ \(]("[a-zA-Z \-]+")[\) ]/.match(line))
        parse_line(line.gsub(match[1], "\"#{match[1]}\""), attempt: attempt + 1)
      elsif (match = /[ ]("\w+)/.match(line))
        parse_line(line.gsub(match[1], "\"#{match[1]}"), attempt: attempt + 1)
      else
        parse_line(line, attempt: attempt + 1)
      end
    end
  end
end
