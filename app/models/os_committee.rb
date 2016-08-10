class OsCommittee < ActiveRecord::Base

  has_one :political_fundraising, inverse_of: :os_committee
  has_one :entity, through: :political_fundraising
end
