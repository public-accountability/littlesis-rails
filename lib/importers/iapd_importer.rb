# frozen_string_literal: true

# Uses a sqlite database stored at data/iapd.db
# see github.com/public-accountability/iapd for the code
# to create the database.

require 'sqlite3'

class IapdImporter
  DATABASE_FILE = Rails.root.join('data/iapd.db').to_s.freeze

  def self.run
    ColorPrinter.print_green 'Importing Advisors'
    import_advisors
    ColorPrinter.print_green 'Importing Schedule A'
    import_schedule_a
    ColorPrinter.print_green 'Processing Advisors'
    process_advisors
    ColorPrinter.print_green 'Processing Schedule A'
    process_schedule_a
  end

  def self.import_advisors
    db.execute('SELECT * FROM advisors') do |row|
      ed = ExternalData
             .find_or_initialize_by(dataset: :iapd_advisors, dataset_id: row['crd_number'])
             .merge_data(advisor_data(row))
      ed.save || Rails.logger.warn("Failed to save advisor: #{row}")
    end
  end

  # Each row in owners_schedule_a represents a relationship between
  # the an owner/executive and an adivsor.
  def self.import_schedule_a
    db.execute(<<~SQL) do |row|
      SELECT owners_schedule_a.*,
             JSON_EXTRACT(advisors.names, '$[0]') as advisor_name
      FROM owners_schedule_a
      LEFT JOIN advisors ON advisors.crd_number = owners_schedule_a.advisor_crd_number AND owners_schedule_a.advisor_crd_number IS NOT NULL
    SQL

      dataset_id = "#{row['owner_key']}-#{row['advisor_crd_number']}"

      ed = ExternalData
             .find_or_initialize_by(dataset: :iapd_schedule_a, dataset_id: dataset_id)
             .merge_data(schedule_a_data(row))
      ed.save || Rails.logger.warn("Failed to save owner: #{row}")
    end
  end

  def self.process_advisors
    ExternalData.iapd_advisors.find_each do |external_data|
      ExternalEntity
        .iapd_advisors
        .find_or_create_by!(external_data: external_data)
        .automatch
    end
  end

  def self.process_schedule_a
    ExternalData.iapd_schedule_a.find_each do |external_data|
      category_id = if external_data.data_wrapper.owner_primary_ext == 'Person'
                      Relationship::POSITION_CATEGORY
                    else
                      Relationship::OWNERSHIP_CATEGORY
                    end

      ExternalRelationship
        .iapd_schedule_a
        .find_or_create_by!(external_data: external_data, category_id: category_id)
    end
  end

  ## Helpers ##

  # Some of the text fields in iapd.db are JSON and need to be parsed first.
  # See the iapd.sql file in public-accountability/iapd for how these columns were generated.

  def self.advisor_data(row)
    row
      .to_h
      .slice('crd_number', 'first_filename', 'latest_filename', 'latest_aum', 'latest_filing_id', 'latest_date_submitted')
      .merge!('names' => JSON.parse(row['names']),
              'filing_ids' => JSON.parse(row['filing_ids']),
              'sec_file_numbers' => JSON.parse(row['sec_file_numbers']))
  end

  def self.schedule_a_data(row)
    row
      .to_h
      .slice('owner_key', 'advisor_crd_number', 'advisor_name')
      .merge!('records' => JSON.parse(row['records']),
              'filing_ids' => JSON.parse(row['filing_ids']))
  end

  def self.db
    @db ||= SQLite3::Database.new(DATABASE_FILE, results_as_hash: true, readonly: true)
  end
end
