# frozen_string_literal: true

module FEC
  module DonorMaker
    def self.run
      IndividualContribution.where(donor: nil).find_each do |ic|
        Donor.find_or_create_from_individual_contribution(ic)
      end
    end
  end
end
