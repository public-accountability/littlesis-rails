class OsMatch < ActiveRecord::Base
 include SoftDelete
 # has_paper_trail
  
  belongs_to :os_donation
  belongs_to :donation, inverse_of: :os_matches
  belongs_to :donor, class_name: "Entity", foreign_key: "donor_id", inverse_of: :matched_contributions
  belongs_to :recipient, class_name: "Entity", foreign_key: "recip_id", inverse_of: :donors
  belongs_to :committee, class_name: "Entity", foreign_key: "cmte_id", inverse_of: :committee_donors
  belongs_to :reference
  belongs_to :relationship, inverse_of: :os_matches

  validates_presence_of :os_donation_id, :donor_id

  after_create :post_process

  def post_process
    set_recipient_and_committee
    update_donation_relationship
    create_reference
  end

  def set_recipient_and_committee
    # if the ids are the same, then the cmteid is the primary recipient
    if os_donation.recipid == os_donation.cmteid
      cmte = find_or_create_cmte
      update_attributes :committee => cmte, :recipient => cmte
    else
      update_attributes :recip_id => find_recip_id(os_donation.recipid), :committee => find_or_create_cmte
    end
  end

  def update_donation_relationship
    return nil unless relationship.nil?
    return nil if recipient.nil?

    r = Relationship.find_or_create_by!(
      entity1_id: donor.id,
      entity2_id: recipient.id,
      category_id: 5)
    update_attribute(:relationship, r)
    
    r.last_user_id = 1    
    r.description1 = "Campaign Contribution" 
    r.description2 = "Campaign Contribution"
    
    r.update_os_donation_info

    r.update_start_date_if_earlier os_donation.date
    r.update_end_date_if_later os_donation.date
    
    r.save

  end

  #  Int -> Int | Nil
  def find_recip_id(crp_id)
    elected = ElectedRepresentative.includes(:entity).find_by(crp_id: crp_id, entity: {is_deleted: false})
    return elected.entity.id unless elected.nil?
    candidate = PoliticalCandidate.includes(:entity).find_by(crp_id: crp_id, entity: {is_deleted: false})
    return candidate.entity.id unless candidate.nil?
    logger.info "Could not find recipient with id: #{crp_id}"
    return nil
  end

  # must happen after relationship is created
  def create_reference
    unless relationship.nil?
      ref = Reference.find_or_create_by!(
        name: os_donation.reference_name, 
        source: os_donation.reference_source, 
        publication_date: os_donation.date.to_s,
        object_model: 'Relationship',
        object_id: relationship.id,
        ref_type: 2,
        last_user_id: 1)
      update_attribute(:reference, ref)
    end
  end

  # output: <Entity> or Nil
  def find_or_create_cmte
    fundraising = PoliticalFundraising.includes(:entity).find_by(fec_id: os_donation.cmteid, entity: {is_deleted: false})
    if fundraising.nil?
      cmte = OsCommittee.find_by(cmte_id: os_donation.cmteid, cycle: os_donation.cycle)
      if cmte.nil?
        return nil
      else
        return OsMatch.create_new_cmte(cmte)
      end
    else
      return fundraising.entity
    end
  end

  # input <OsCommittee>
  # output <Entity> or nil
  def self.create_new_cmte(cmte)
    if cmte.name.blank?
      return nil
    else
      entity = Entity.create!(name: cmte.name, primary_ext: "Org")
      ExtensionRecord.create!(entity_id: entity.id, definition_id: 11, last_user_id: 1)
      PoliticalFundraising.create!(fec_id: cmte.cmte_id, entity_id: entity.id)
      entity
    end
  end

end
