# frozen_string_literal: true

module FEC
  # Populates additional tables
  #  - donors
  #  - addresses
  #  - organizations
  #  - donor_individual_contributions
  #  - donor_employers
  #  - organization_operating_expenditures
  module DataProcessor
    def self.run
      IndividualContribution.find_each do |ic|
        Donor.create_from_individual_contribution(ic)
      end

      Committee.all.pluck(:rowid, :CONNECTED_ORG_NM).each do |(committee_id, connected_org_name)|
        if connected_org_name.present?
          organization = FEC::Organization.find_or_create_by!(name: OrgName.parse(connected_org_name).clean)

          FEC::Database.exec_query(
            "INSERT INTO committee_connected_organizations (committee_rowid, organization_id) VALUES (?, ?) ON CONFLICT (committee_rowid) DO NOTHING",
            [committee_id, organization.id]
          )
        end
      end

      Expenditure.select(:SUB_ID, :NAME).find_each do |expenditure|
        if expenditure.NAME.present?
          normalized_name = NameNormalizer.parse(str)
          if normalized_name.type == :Org
            organization = FEC::Organization.find_or_create_by!(name: normalized_name)

            FEC::Database.exec_query(
              "INSERT INTO organization_operating_expenditures (organization_id, operating_expenditures_sub_id) VALUES (?, ?) ON CONFLICT (operating_expenditures_sub_id) DO NOTHING",
              [organization.id, expenditure.SUB_ID]
            )
          end
        end
      end
    end
  end
end
