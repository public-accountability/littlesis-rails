# frozen_string_literal: true

module ExternalDataset
  module CommcandExtractor
    def self.each(filepath)
      errors = 0
      Utility.zip_entry_each_line(zip: filepath, file: 'COMMCAND.CSV') do |line|
        # parsed_line = parse_line(fix_names(line.encode('ASCII', invalid: :replace, undef: :replace, replace: '').chomp))
        parsed_line = parse_line(fix_names(line.chomp))
        # parsed_line = CSV.parse_line(line.encode('ASCII', invalid: :replace, undef: :replace, replace: ''))
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

    NAME_FIXES = [
      ['Maria D Kaufer For Ad28 District Leader ("Ad28" = "Assembly District 28")"', 'Maria D Kaufer For Ad28 District Leader (Assembly District 28)'],
      ['The Orchard Park Republican Alliance Pac ("Opgopa" Or "Opra")', 'The Orchard Park Republican Alliance Pac (\"Opgopa\" Or \"Opra\")'],
      ['Police Accountability Board Alliance ("Paba" Or "The Alliance")', 'Police Accountability Board Alliance (\"Paba\" Or \"The Alliance\")'],
      ['Local 32bj Seiu American Dream Political Action Fund ("32bj American Dream Fund"', 'Local 32bj Seiu American Dream Political Action Fund (\"American Dream Fund\")'],
      ['Queens County Gop ("Gop" - "Grand Old Party")', 'Queens County GOP']
    ].freeze

    private_class_method def self.fix_names(line)
      NAME_FIXES.each do |(text, replacement)|
        return line.gsub(text, replacement) if line.include?(text)
      end
      line
    end
  end
end
