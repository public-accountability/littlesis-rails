# frozen_string_literal: true

require 'zip'

# This dataset is millions of row and is processed one-by-one. It takes many hours,
# even if only a small number of disclosures are new.
module NYSDisclosureImporter
  REMOTE_URL = 'https://cfapp.elections.ny.gov/NYSBOE/download/ZipDataFiles/ALL_REPORTS.zip'
  LOCAL_PATH = Rails.root.join('data/nys_campaign_finance_all_reports.zip').to_s
  FILENAME = 'ALL_REPORTS.out'
  # See EFSSCHED.TXT and EFSRECB.TXT in the all_reports zip file for details
  HEADERS = %w[FILER_ID FREPORT_ID TRANSACTION_CODE E_YEAR T3_TRID DATE1_10 DATE2_12 CONTRIB_CODE_20 CONTRIB_TYPE_CODE_25 CORP_30 FIRST_NAME_40 MID_INIT_42 LAST_NAME_44 ADDR_1_50 CITY_52 STATE_54 ZIP_56 CHECK_NO_60 CHECK_DATE_62 AMOUNT_70 AMOUNT2_72 DESCRIPTION_80 OTHER_RECPT_CODE_90 PURPOSE_CODE1_100 PURPOSE_CODE2_1 EXPLANATION_110 XFER_TYPE_120 CHKBOX_130 CREREC_UID CREREC_DATE].freeze

  def self.run
    Utility.stream_file(url: REMOTE_URL, path: LOCAL_PATH) if should_download?
    import
    process
  end

  def self.import
    loop_rows do |row|
      # This dataset has no unique identifier per row
      # We create one by joining 5 fields: filer id, report id, transaction code, election year, and transaction id (T3_TRID)
      dataset_id = row.values_at('FILER_ID', 'FREPORT_ID', 'TRANSACTION_CODE', 'E_YEAR', 'T3_TRID').map(&:strip).join('-')

      ExternalData
        .nys_disclosure
        .find_or_initialize_by(dataset_id: dataset_id)
        .merge_data(row)
        .save!
    rescue NoMethodError => e
      # A few rows have null values for fields that compose the dataset_id
      if e.message.include?('strip')
        Rails.logger.warn "[NYSDisclosureImporter] Failed to import row: #{row}"
        next
      else
        raise
      end
    end
  end

  def self.process
    ExternalData.nys_disclosure.find_each do |external_data|
      ExternalRelationship
        .nys_disclosure
        .find_or_create_by!(external_data: external_data, category_id: Relationship::DONATION_CATEGORY)
    end
  end

  def self.loop_rows
    errors = 0
    Utility.zip_entry_each_line(zip: LOCAL_PATH, file: FILENAME) do |line|
      line_encoded = line.encode('ASCII', invalid: :replace, undef: :replace, replace: '')
      yield HEADERS.zip(CSV.parse_line(line_encoded, liberal_parsing: true)).to_h
    rescue CSV::MalformedCSVError
      errors += 1
      Rails.logger.warn "[NYSDisclosureImporter] Failed to parse line: #{line}"
    end
    Rails.logger.warn("[NYSDisclosureImporter] skipped #{errors} lines with errors") unless errors.zero?
  end

  private_class_method def self.should_download?
    Utility.file_is_empty_or_nonexistent(LOCAL_PATH) || (File.ctime(LOCAL_PATH).to_date != Time.zone.today)
  end
end
