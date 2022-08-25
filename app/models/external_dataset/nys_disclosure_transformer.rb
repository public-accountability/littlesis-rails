# frozen_string_literal: true

# 1 filer_id
# 2 filer_previous_id
# 3 cand_comm_name
# 4 election_year
# 5 election_type
# 6 county_desc
# 7 filing_abbrev
# 8 filing_desc
# 9 r_amend
# 10 filing_cat_desc
# 11 filing_sched_abbrev
# 12 filing_sched_desc
# 13 loan_lib_number
# 14 trans_number
# 15 trans_mapping
# 16 sched_date
# 17 org_date
# 18 cntrbr_type_desc
# 19 cntrbn_type_desc
# 20 transfer_type_desc
# 21 receipt_type_desc
# 22 receipt_code_desc
# 23 purpose_code_desc
# 24 r_subcontractor
# 25 flng_ent_name
# 26 flng_ent_first_name
# 27 flng_ent_middle_name
# 28 flng_ent_last_name
# 29 flng_ent_add1
# 30 flng_ent_city
# 31 flng_ent_state
# 32 flng_ent_zip
# 33 flng_ent_country
# 34 payment_type_desc
# 35 pay_number
# 36 owned_amt
# 37 org_amt
# 38 loan_other_desc
# 39 trans_explntn
# 40 r_itemized
# 41 r_liability
# 42 election_year_str
# 43 office_desc
# 44 district
# 45 dist_off_cand_bal_prop

module ExternalDataset
  class NYSDisclosureTransformer
    class RowLengthError < Exceptions::LittleSisError
      def message
        "row is empty or does not have the correct number of columns"
      end
    end

    def self.fix_quotes(line)
      chars = line.chars
      out = +''

      (0...chars.length).each do |i|
        out << chars[i]

        next if i.zero? || i == (chars.length - 1)

        if chars[i] == '"' && !(chars[i - 1] == ',' || chars[i + 1] == ',')
          out << '"'
        end
      end
      out.freeze
    end

    def self.parse_line(line)
      begin
        row = CSV.parse_line(line)
      rescue CSV::MalformedCSVError => e
        row = CSV.parse_line(fix_quotes(line))
      end

      raise RowLengthError if row.nil? || row.length != 45
      row
    end

    def self.extract_csvs(dir, out)
      # Unzip the files
      Dir[dir.join('*.zip')].each do |f|
        system "unzip #{f} -x \"*.pdf\" -d #{dir}", exception: true
        FileUtils.rm(f)
      end

      # # Unzip the inner zip files
      Dir[dir.join('*.zip')].each do |f|
        system "unzip #{f} -d #{dir}", exception: true
        FileUtils.rm(f)
      end

      # Combine all csvs into a single file and convert to UTF-8
      Dir[dir.join('*.csv')].each do |f|
        system "iconv -c -f Windows-1252 -t utf8 #{f} >> #{out}", exception: true
        FileUtils.rm(f)
      end
    end

    def self.run
      verbose = false
      FileUtils.mkdir_p Rails.root.join('data/external_data/csv/nys')

      # File Paths
      original_directory = Rails.root.join('data/external_data/original/nys')
      combined = original_directory.join('nys_disclosures.csv').to_s
      output_dir = Rails.root.join('data/external_data/csv/nys')

      extract_csvs(original_directory, combined)

      # Skip duplicates and lines that fail to parse
      seen_trans_numbers = Set.new
      printer.print_blue "Copying #{combined} to #{output_dir}"

      CSV.open(output_dir.join('nys_disclosures.csv'), 'w') do |destination_csv|
        File.open(output_dir.join('nys_disclosures_duplicates.csv'), 'w') do |duplicates_f|
          File.open(output_dir.join('nys_disclosures_errors.csv'), 'w') do |errors_f|
            File.foreach(combined) do |line|
              row = parse_line(line.delete("\r").chomp)

              if seen_trans_numbers.include?(row[13])
                printer.print_red("skipping duplicate nys_disclosure row with trans number #{row[13]}") if verbose
                duplicates_f.write line
              else
                seen_trans_numbers << row[13]
                destination_csv.add_row(row)
              end

            rescue CSV::MalformedCSVError, RowLengthError => e
              printer.print_red e.message if verbose
              errors_f.write line
            end
          end
        end
      end

      printer.print_blue `wc -l #{output_dir.join('*.csv')}`
    end

    private_class_method def self.printer
      @printer ||= ColorPrinter.with_logger(:warn)
    end
  end
end
