class OsCommittee < ActiveRecord::Base
  # has_one :political_fundraising, inverse_of: :os_committees
  # has_one :entity, through: :political_fundraising
end
