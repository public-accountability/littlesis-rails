# frozen_string_literal: true

module ExternalDataset
  class NYSDisclosureExtractor
    # See EFSSCHED.TXT and EFSRECB.TXT in the all_reports zip file for details
    HEADERS = %w[filer_id freport_id transaction_code e_year t3_trid date1_10 date2_12 contrib_code_20 contrib_type_code_25 corp_30 first_name_40 mid_init_42 last_name_44 addr_1_50 city_52 state_54 zip_56 check_no_60 check_date_62 amount_70 amount2_72 description_80 other_recpt_code_90 purpose_code1_100 purpose_code2_1 explanation_110 xfer_type_120 chkbox_130 crerec_uid crerec_date].freeze

    def initialize(filepath)
      @filepath = filepath
    end

    def each
      loop_rows do |row|
        # This dataset has no unique identifier per row
        # We create one by joining 5 fields: filer id, report id, transaction code, election year, and transaction id (T3_TRID)
        dataset_id = row.values_at('filer_id', 'freport_id', 'transaction_code', 'e_year', 't3_trid').map(&:strip).join('-')
        yield row.concat([dataset_id])
      rescue NoMethodError => e
        # A few rows have null values for fields that compose the dataset_id
        if e.message.include?('strip')
          Rails.logger.warn "[NYSDisclosure] Failed to import row: #{row}"
          next
        else
          raise
        end
      end
    end

    private

    def loop_rows
      errors = 0
      Utility.zip_entry_each_line(zip: @filepath, file: 'ALL_REPORTS.out') do |line|
        line_encoded = line.encode('ASCII', invalid: :replace, undef: :replace, replace: '')
        yield HEADERS.zip(CSV.parse_line(line_encoded, liberal_parsing: true)).to_h
      rescue CSV::MalformedCSVError
        errors += 1
        Rails.logger.warn "[NYSDisclosure] Failed to parse line: #{line}"
      end
      unless errors.zero?
        Rails.logger.warn("[NYSDisclosure] skipped #{errors} lines with errors")
      end
    end
  end
end
