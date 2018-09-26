require 'csv'

# Various helper functions used by scripts and rake tasks.

module Utility
  def self.save_hash_array_to_csv(file_path, data, mode: 'wb')
    CSV.open(file_path, mode) do |csv|
      csv << data.first.keys
      data.each { |hash| csv << hash.values }
    end
  end
end
