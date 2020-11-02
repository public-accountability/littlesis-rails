# frozen_string_literal: true

# rubocop:disable Rails/SkipsModelValidations

module FEC
  # Changes data stored as empty string to be null values
  module DataCleaner
    def self.run
      Committee.where(:CAND_ID => '').update_all(:CAND_ID => nil)
      Committee.where(:CONNECTED_ORG_NM => '').update_all(:CONNECTED_ORG_NM => nil)
      IndividualContribution.where(:CITY => '').update_all(:CITY => nil)
      IndividualContribution.where(:STATE => '').update_all(:STATE => nil)
      IndividualContribution.where(:ZIP_CODE => '').update_all(:ZIP_CODE => nil)
      IndividualContribution.where(:EMPLOYER => '').update_all(:EMPLOYER => nil)
      IndividualContribution.where(:OCCUPATION => '').update_all(:OCCUPATION => nil)
    end
  end
end


# rubocop:enable Rails/SkipsModelValidations
