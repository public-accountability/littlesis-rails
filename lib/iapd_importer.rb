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
    db.execute('SELECT * FROM owners_schedule_a') do |row|
      dataset_id = "#{row['owner_key']}-#{row['advisor_crd_number']}"

      ed = ExternalData
             .find_or_initialize_by(dataset: :iapd_schedule_a, dataset_id: dataset_id)
             .merge_data(schedule_a_data(row))
      ed.save || Rails.logger.warn("Failed to save owner: #{row}")
    end
  end

  # Some of the text fields in iapd.db are JSON and need to be parsed first.
  # See the iapd.sql file in public-accountability/iapd for how these columns were generated.

  def self.advisor_data(row)
    row
      .to_h
      .slice('crd_number', 'first_filename', 'latest_filename', 'latest_num', 'latest_filing_id')
      .merge!('names' => JSON.parse(row['names']),
              'filing_ids' => JSON.parse(row['filing_ids']))
  end

  def self.schedule_a_data(row)
    row
      .to_h
      .slice('owner_key', 'advisor_crd_number')
      .merge!('records' => JSON.parse(row['records']),
              'filing_ids' => JSON.parse(row['filing_ids']))
  end

  def self.db
    @db ||= SQLite3::Database.new(DATABASE_FILE, results_as_hash: true, readonly: true)
  end
end
