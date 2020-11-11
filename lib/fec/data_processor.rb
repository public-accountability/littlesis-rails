# frozen_string_literal: true

module FEC
  # Populates additional tables
  #  - donors
  #  - donor_individual_contributions
  module DataProcessor
    def self.run
      FEC.logger.info "PROCESSING: creating donor_individual_contributions"

      FEC::IndividualContribution.all.find_each do  |ic|
        next if ic.NAME.blank?

        donor_name = NameParser.format(ic.NAME)
        employer = OrgName.parse(ic.EMPLOYER).clean if ic.EMPLOYER.present?

        donor = FEC::Donor.find_or_create_by!(name: donor_name,
                                              city: ic.CITY,
                                              state: ic.STATE,
                                              zip_code: ic.ZIP_CODE,
                                              employer: employer,
                                              occupation: ic.OCCUPATION)

        FEC::Database.exec_query(
          "INSERT OR IGNORE INTO donor_individual_contributions VALUES (?, ?)",
          [donor.id, ic.SUB_ID]
        )
      end
    end
  end
end
