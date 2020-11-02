# frozen_string_literal: true

module FEC
  class Donor < ApplicationRecord
    before_create :ensure_nulls

    validates :name, presence: true
    has_many :individual_contributions, through: :donor_individual_contributions
    has_one :employer, through: :donor_employers

    # When fields are fully-filled and not yet in the database this will create:
    #   DonorContribution
    #   Organization
    #   DonorEmployee
    def self.create_from_individual_contribution(ic)
      donor_name = NameParser.format(ic.NAME)
      employer = OrgName.parse(ic.EMPLOYER).clean if ic.EMPLOYER.present?

      donor = find_or_create_by(name: donor_name, city: ic.CITY, state: ic.STATE, zip_code: ic.ZIP_CODE, employer: employer, occupation: ic.OCCUPATION)

      DonorContribution.find_or_create_by!(donor_id: donor.id, individual_contribution_sub_id: ic.id)

      if employer
        employer_org = FEC::Organization.find_or_create_by!(name: employer)
        DonorEmployee.find_or_create_by!(donor_id: donor.id, organization_id: employer_org.id)
      end
    end

    private

    def ensure_nulls
      %i[city state zip_code employer occupation].each do |attr|
        write_attribute(attr, nil) if read_attribute(attr) == ''
      end
    end
  end
end