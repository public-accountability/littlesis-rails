# frozen_string_literal: true

require 'sqlite3'

class IapdImporter
  DATABASE_FILE = Rails.root.join('data/iapd.db').to_s.freeze

  def self.run
    import_advisors
    import_owners
  end

  def self.import_owners
    db.execute('SELECT * FROM owners') do |row|
      ed = ExternalData
             .find_or_initialize_by(dataset: :iapd_owners, dataset_id: row['owner_key'])
             .setup_data_column
      ed.data << row.to_h
      ed.save || Rails.logger.warn("Failed to save owner: #{row}")
    end
  end

  def self.import_advisors
    db.execute('SELECT * FROM advisors') do |row|
      ed = ExternalData
             .find_or_initialize_by(dataset: :iapd_advisors, dataset_id: row['crd_number'])
             .setup_data_column
      ed.data << row.to_h
      ed.save || Rails.logger.warn("Failed to save advisor: #{row}")
    end
  end

  def self.db
    @db ||= SQLite3::Database.new(DATABASE_FILE, results_as_hash: true, readonly: true)
  end
end
