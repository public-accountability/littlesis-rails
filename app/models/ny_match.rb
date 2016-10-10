class NyMatch < ActiveRecord::Base
  
  belongs_to :ny_disclosure
  belongs_to :donor, class_name: "Entity", foreign_key: "donor_id"
  belongs_to :recipient, class_name: "Entity", foreign_key: "recip_id"
  belongs_to :relationship
  belongs_to :user, foreign_key: "matched_by"

  validates_presence_of :ny_disclosure_id, :donor_id

end
