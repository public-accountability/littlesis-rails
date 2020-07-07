# frozen_string_literal: true

require 'zip'

module NYSFilerImporter
  REMOTE_URL = 'https://cfapp.elections.ny.gov/NYSBOE/download/ZipDataFiles/commcand.zip'
  LOCAL_PATH = Rails.root.join('data/nys_campaign_finance_commcand.zip').to_s
  HEADERS = %w[filer_id name filer_type status committee_type office district treas_first_name treas_last_name address city state zip].freeze

  def self.run
    Utility.stream_file_if_not_exists(url: REMOTE_URL, path: LOCAL_PATH)
    import
    process
  end

  def self.import
    extract_rows do |row|
      ExternalData
        .nys_filer
        .find_or_initialize_by(dataset_id: row.fetch('filer_id'))
        .merge_data(row)
        .save!
    end
  end

  def self.process
    ExternalData.nys_filer.find_each do |external_data|
      ExternalEntity
        .nys_filer
        .find_or_create_by!(external_data: external_data)
        .automatch
    end
  end

  def self.extract_rows
    errors = 0
    Utility.zip_entry_each_line(zip: LOCAL_PATH, file: 'COMMCAND.txt') do |line|
      parsed_line = parse_line(line.encode('ASCII', invalid: :replace, undef: :replace, replace: ''))
      if parsed_line == :error
        Rails.logger.warn "[NYSFilerImporter] Could not import line\n    #{line.strip}\n"
        errors += 1
      else
        yield parsed_line
      end
    end
    Rails.logger.warn "[NYSFilerImporter] Skipped #{errors} lines with errors."
  end

  def self.parse_line(line, attempt: 0)
    return :error if attempt == 2

    HEADERS.zip(CSV.parse_line(line)).to_h
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
