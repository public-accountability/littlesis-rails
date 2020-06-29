# frozen_string_literal: true

require 'zip'

module NYSFilerImporter
  FILER_REMOTE_URL = 'https://cfapp.elections.ny.gov/NYSBOE/download/ZipDataFiles/commcand.zip'
  FILER_LOCAL_PATH = Rails.root.join('data/nys_campaign_finance_commcand.zip')
  HEADERS = %w[filer_id name filer_type status committee_type office district treas_first_name treas_last_name address city state zip].freeze

  def self.run
    download_data
    import
  end

  def self.process
    ExternalData.nys_filer.find_each do |external_data|
      ExternalEntity
        .nys_filer
        .find_or_create_by!(external_data: external_data)
        .automatch
    end
  end

  def self.download_data
    unless FILER_LOCAL_PATH.exist?
      File.open(FILER_LOCAL_PATH, 'wb') do |f|
        f.write HTTParty.get(FILER_SOURCE_URL).body
      end
    end
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

  def self.extract_rows
    Zip::File.open(FILER_LOCAL_PATH) do |zip_file|
      zip_file.get_entry('COMMCAND.txt').get_input_stream do |io|
        io.each do |line|
          yield parse_line(line)
        end
      end
    end
  end

  def self.parse_line(line)
    begin
      HEADERS.zip(CSV.parse_line(line)).to_h
    rescue CSV::MalformedCSVError
      # Try to correct middle names in quotes that are not escaped
      # example: 'Foo "Middle" Bar'
      if (match = /"(\w+\")[^,]/.match(line))
        line.gsub!(match[1], "\"#{match[1]}\"")
        retry
      else
        raise
      end
    end
  end
end
