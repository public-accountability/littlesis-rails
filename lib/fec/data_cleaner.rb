# frozen_string_literal: true

# rubocop:disable Rails/SkipsModelValidations

module FEC
  # Changes data stored as empty string to be null values
  module DataCleaner
    def self.run
      FEC.logger.info "DATA CLEANING started"
      Committee.where(:CAND_ID => '').update_all(:CAND_ID => nil)
      Committee.where(:CONNECTED_ORG_NM => '').update_all(:CONNECTED_ORG_NM => nil)
      FEC.logger.info "DATA CLEANING complete"
    end
  end
end

# rubocop:enable Rails/SkipsModelValidations
