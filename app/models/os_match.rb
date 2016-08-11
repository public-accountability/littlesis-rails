class OsMatch < ActiveRecord::Base
  include SoftDelete
  has_paper_trail
  
  belongs_to :os_donation
  belongs_to :donation, inverse_of: :os_matches
  belongs_to :donor, class_name: "Entity", foreign_key: "donor_id", inverse_of: :matched_contributions
  belongs_to :recipient, class_name: "Entity", foreign_key: "recip_id", inverse_of: :donors
  belongs_to :committee, class_name: "Entity", foreign_key: "cmte_id", inverse_of: :committee_donors
  belongs_to :reference
  belongs_to :relationship, inverse_of: :os_matches

  validates_presence_of :os_donation_id, :donor_id


  def self.match_a_donation(os_donation_id, donor_id)
    OsMatch.find_or_create_by(
      os_donation_id: os_donation_id,
      donor_id: donor_id )
  end

  def update_or_create_relationship
    # if the ids are the same, then the cmteid is the primary recipient
    if @os_donation.recipid == @os_donation.cmteid
      cmte = find_or_create_cmte
      @committee = cmte
      @recipient = cmte
    end
    
  end

  def update_donation_relationship
    return nil unless relationship.nil?
    
    r = Relationship.find_or_initialize_by(
      entity1_id: donor.id,
      entity2_id: recipient.id,
      category_id: 5 )

    r.last_user_id = 1    
    r.description1 = "Campaign Contribution" 
    r.description2 = "Campaign Contribution"

    if r.amount.nil?
       r.amount = 0
    end
    
    if r.filings.nil?
       r.filings = 0
    end
    
    r.amount += os_donation.amount
    r.filings += 1
    
    r.update_start_date_if_earlier os_donation.date
    r.update_end_date_if_later os_donation.date
    
    r.save
    update_attribute(:relationship, r)
  end

  def create_reference
  end

  def find_or_create_cmte
  end

  
end
