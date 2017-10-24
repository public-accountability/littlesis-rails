require 'csv'

module Query
  def self.save_hash_array_to_csv(file_path, data)
    CSV.open(file_path, "wb") do |csv|
      csv << data.first.keys
      data.each { |hash| csv << hash.values }
    end
  end
end
