#!/usr/bin/env -S rails runner

require 'csv'

# Open the CSV file
# Includes the FEC name and a pre-matched LS entity id called donor_id
TOP_FEC_DONORS = Rails.root.join("data/top-2024-fec-donors-clean-up.csv")

USER_ID = 22227
PaperTrail.request.whodunnit = USER_ID.to_s

TOP_FEC_DONOR_LIST_ID = 3730
TOP_FEC_DONOR_RECIPIENT_LIST_ID = 3731
TOP_FEC_DONOR_BY_STATE_LIST_ID = {
  'AL' => 3736,
  'AR' => 3737,
  'AZ' => 3738,
  'CA' => 3739,
  'CO' => 3740,
  'CT' => 3741,
  'DC' => 3742,
  'DE' => 3743,
  'FL' => 3744,
  'GA' => 3745,
  'HI' => 3746,
  'IL' => 3747,
  'IN' => 3748,
  'KS' => 3749,
  'MA' => 3750,
  'MD' => 3751,
  'MI' => 3752,
  'NC' => 3753,
  'ND' => 3754,
  'NE' => 3755,
  'NJ' => 3756,
  'NM' => 3757,
  'NV' => 3758,
  'NY' => 3759,
  'OH' => 3760,
  'PA' => 3761,
  'SD' => 3762,
  'TN' => 3763,
  'TX' => 3764,
  'UT' => 3765,
  'VA' => 3766,
  'WA' => 3767,
  'WI' => 3768,
  'WY' => 3769,
}

def create_fec_match(donor_id, fec_contribution_id)
  @fec_contribution = ExternalDataset.fec_contributions.find(fec_contribution_id)
  fec_match = FECMatch.find_by(sub_id: @fec_contribution.sub_id)
  if !fec_match.present?
    @entity = Entity.find(donor_id)
    fec_match = FECMatch.create!(donor: @entity, fec_contribution: @fec_contribution)

    # Add the recipient to a Recipient of top 100 FEC Donor list
    add_entity_to_list(TOP_FEC_DONOR_RECIPIENT_LIST_ID, fec_match.recipient_id)
  end
end

def add_entity_to_list(list_id, entity_id)
  list_entity = ListEntity.find_by({list_id: list_id, entity_id: entity_id})
  if !list_entity.present?
    list_entity = ListEntity.create({
      list_id: list_id,
      entity_id: entity_id
    })
  end
end

# Loop through the rows of the CSV
CSV.foreach(TOP_FEC_DONORS, headers: true) do |row|

  puts row
  # Add the donor to a top 100 FEC donor list using the LS id
  add_entity_to_list(TOP_FEC_DONOR_LIST_ID, row['entity_id'])

  # Look up FEC contributions based on name
  fec_contributions = ExternalDataset.fec_contributions.where(name: row['name'], state: row['state'], fec_year: 2024)

  # Loop through each contribution and
  # run an FEC Match with the LS id and the FEC contribution id
  fec_contributions.each { |fec_contribution|

    create_fec_match(row['entity_id'], fec_contribution.id)

    # Add the donor to a list of the top 100 FEC Donors by state
    if TOP_FEC_DONOR_BY_STATE_LIST_ID["#{fec_contribution.state}"]
      add_entity_to_list(TOP_FEC_DONOR_BY_STATE_LIST_ID["#{fec_contribution.state}"], row['entity_id'])
    end
  }

end
