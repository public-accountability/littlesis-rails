# frozen_string_literal: true

module FEC
  module CsvMaker
    def self.run
      FEC.loop_tables do |table|
        if File.exist?(table.csv_localpath) && File.stat(table.csv_localpath).size.positive?
          FEC.logger.info "SKIPPING  #{table.csv_localpath}"
          next
        else
          FEC.logger.info "CREATING  #{table.csv_localpath}"
        end

        line_parser = line_parser_for(table)

        CSV.open(table.csv_localpath, 'w', col_sep: ',', quote_char: '"') do |output|
          Zip::File.open(table.zip_localpath) do |zip|
            zip.get_entry(table.zip_entry).get_input_stream.each_line do |line|
              output << line_parser.call(line)
            end
          end
        end
      end
    end

    # Right now all this does is ensure blank string are stored as null
    def self.cast_value(x)
      if x.is_a?(String) && x.strip == ''
        nil
      else
        x
      end
    end

    def self.line_parser_for(table)
      lambda do |line_from_csv|
        line = CSV.parse_line(line_from_csv, col_sep: '|', quote_char: "\x00")
        line = line[0..24] if table.name == 'operating_expenditures'
        line.map! { |v| cast_value(v) }
        line.concat([table.year]) # For column FEC_YEAR
      end
    end
  end
end
