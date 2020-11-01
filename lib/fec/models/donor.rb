# frozen_string_literal: true

module FEC
  class Donor < ApplicationRecord
    before_create :ensure_nulls

    validates :name, presence: true
    has_many :individual_contributions, through: :donor_individual_contributions
    has_one :employer, through: :donor_employers

    def self.find_or_create_from_individual_contribution(ic)
      donor = find_or_create_by(name: ic.NAME,
                                city: ic.CITY,
                                state: ic.STATE,
                                zip_code: ic.ZIP_CODE,
                                employer: ic.EMPLOYER,
                                occupation: ic.OCCUPATION)

      ic.update!(donor: donor) if donor
    end

    private

    def ensure_nulls
      %i[city state zip_code employer occupation].each do |attr|
        write_attribute(attr, nil) if read_attribute(attr) == ''
      end
    end
  end
end
