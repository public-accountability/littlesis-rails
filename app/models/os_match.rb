class OsMatch < ActiveRecord::Base
  include SoftDelete
  has_paper_trail
  
  belongs_to :os_donation
  belongs_to :donation, inverse_of: :os_matches
  belongs_to :donor, class_name: "Entity", foreign_key: "donor_id", inverse_of: :contributions
  belongs_to :recipient, class_name: "Entity", foreign_key: "recip_id", inverse_of: :donors
  belongs_to :reference
  belongs_to :relationship, inverse_of: :os_matches

  validates_presence_of :os_donation_id, :donor_id
end
