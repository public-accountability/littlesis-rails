class PoliticalFundraising < ApplicationRecord
  include SingularTable

  has_paper_trail on: [:update],
                  meta: { entity1_id: :entity_id }

  belongs_to :entity, inverse_of: :political_fundraising

  # There are multiple entries of the same committee in the OsCommitte
  # table. Open Secrets provides a different copy of the committee for
  # each cycle of the same committee.
  # Accordingly a single  PoliticalFundraising entity
  # can point towards multiple versions of OsCommittee
  # All versions of OsCommittee should have the same cmte_id, which will
  # match the fec_id on this model.
  # At some point we could create a join table if those matches seem important,
  # but it's probably just has easy to join on cmte_id.
  # belongs_to  :os_committees, inverse_of: :political_fundraising
end
