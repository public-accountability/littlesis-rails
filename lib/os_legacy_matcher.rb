class OsLegacyMatcher
  attr_reader :relationship_id, :filings, :references
  
  class ReferencesNotFoundError < StandardError
  end
  
  def initialize( relationship_id )
    @relationship_id = relationship_id
    find_filings
    find_references
  end

  def find_filings
    @filings = FecFiling.where(relationship_id: @relationship_id)
  end

  def find_references
    @references = Reference.where(object_id: @relationship_id, object_model: "Relationship")
  end

  def corresponding_os_donation(f)
    d = OsDonation.find_by(fectransid: f.fec_filing_id, cycle: f.crp_cycle.to_s)
    return d unless d.nil?
    d = OsDonation.find_by(fectransid: f.crp_id, cycle: f.crp_cycle.to_s)
    return d unless d.nil?
    d = OsDonation.find_by(cycle: f.crp_cycle.to_s, date: f.start_date, microfilm: f.fec_filing_id, amount: f.amount)
    return d unless d.nil?

    raw_db_info = get_raw_info(f)
    return nil if raw_db_info.nil?
    
    return OsDonation.find_by(
             date: f.start_date,
             amount: f.amount,
             zip: raw_db_info[:zip],
             contrib: raw_db_info[:donor_name],
             recipid: raw_db_info[:recipient_id]
           )
    
  end

  def get_raw_info(filing)
    sql = "SELECT recipient_id, donor_name, zip 
           from littlesis_raw.os_donation 
           where row_id = '#{filing.crp_id}' and 
                 fec_id = '#{filing.fec_filing_id}' and
                 date = '#{filing.start_date}'"
    result = ActiveRecord::Base.connection.execute(sql).to_a
    if result.empty?
      printf("No match found in littlesis_raw: row_id: %s, rec_id: %s, date: %s\n", filing.crp_id, filing.fec_filing_id, filing.start_date)
      return nil
    elsif result.length > 1 
      printf("More than one match found in Littlesis_raw\n")
      return nil
    else
      return {
        recipient_id: result[0][0],
        donor_name: result[0][1],
        zip: result[0][2]
      }
    end
  end

  def match_all
    @filings.each { |f| match_one(f) }
  end
  
  def match_one(filing)
    donation = corresponding_os_donation(filing)
    if donation.nil?
      printf('X')
      no_donation filing
    else
      printf("m")
      create_os_match donation, filing
    end
  end

  # input: <OsDonation>, <FecFiling>
  def create_os_match(donation, filing)
    os_match = OsMatch.find_or_initialize_by(os_donation_id: donation.id)
    if os_match.persisted?
      return nil
    end
    
    os_match.os_donation_id = donation.id

    rel = Relationship.find(@relationship_id)
    os_match.relationship = rel
    os_match.donor_id = rel.entity1_id
    os_match.recip_id = rel.entity2_id
    set_cmte_id(donation, os_match)

    os_match.reference_id = find_reference filing, donation
    change_ref_type os_match.reference_id
    update_source_link os_match.reference_id, donation

    os_match.donation = rel.donation
    os_match.save!
  end

  # <OsDonation>, <OsMatch>
  def set_cmte_id(donation, os_match)
    if Entity.find(os_match.recip_id).org?
      os_match.cmte_id = os_match.recip_id
    else
      os_match.cmte_id = find_or_create_cmte(donation)
    end
  end

  # input: <OsDonation>
  # output: entity_id (integer)
  def find_or_create_cmte(donation)
    fundraising = PoliticalFundraising.includes(:entity).find_by(fec_id: donation.cmteid, entity: {is_deleted: false})
    
    if fundraising.nil?
      cmte = OsCommittee.find_by(cmte_id: donation.cmteid, cycle: donation.cycle)
      if cmte.nil?
        printf("Could not find %s in OsCommittee\n", donation.cmteid)
        return nil
      else
        return create_new_cmte(cmte)
      end
    else
      return fundraising.entity_id
    end
    
  end

  def create_new_cmte(cmte)
    printf("creating new committee %s \n", cmte.name)
    entity = Entity.create!(name: cmte.name, primary_ext: "Org")
    ExtensionRecord.create!(entity_id: entity.id, definition_id: 11, last_user_id: 1)
    PoliticalFundraising.create!(fec_id: cmte.cmte_id, entity_id: entity.id)
    entity.id
  end
  

  def find_reference(filing, donation=nil)
    #raise ReferencesNotFoundError if @references.blank?
    if not @references.blank?
      for r in @references
        if not filing.fec_filing_id.blank? and r.name.include? filing.fec_filing_id
          return r.id
        elsif not filing.crp_id.blank? and r.name.include? filing.crp_id
          return r.id
        elsif not filing.fec_filing_id.blank? and r.source.include? filing.fec_filing_id
          return r.id
        else
          next
        end
      end
    end
    printf(" NO REFERENCE FOUND with filing:  %s rel_id: %s donation_id: %s \n", filing.id, @relationship_id, donation.id)
    printf("creating new reference\n")
    return create_new_ref(donation)
  end
  
  def no_donation(f)
    if f.crp_cycle = 2012
      printf("\n** Count not find a match for FecFiling: %s\n", f.id)
      puts f.inspect
    end
    error_file = File.new("os_legacy_matcher_error_log.txt", "a")
    error_file.write("#{@relationship_id},#{f.id}\n")
  end

  def create_new_ref(donation)
    ref = Reference.find_or_create_by!(
      name: donation.reference_name, 
      source: donation.reference_source, 
      publication_date: donation.date.to_s,
      object_model: 'Relationship',
      object_id: @relationship_id,
      ref_type: 2,
      last_user_id: 1)
    ref.id
  end

  def update_source_link(reference_id, donation)
    if not reference_id.nil?
      Reference.find(reference_id).update_attribute(:source, donation.reference_source)
    end
  end

  def change_ref_type(reference_id)
    if not reference_id.nil?
      Reference.find(reference_id).update_attribute(:ref_type, 2)
    end
  end
  
  def ref_link_helper(ref)
    ref.source[ref.source.rindex('?') + 1, ref.source.length]
  end

end


#  for each donation relationship
#    - get fecFilings
#      - find corresponding OsDonation
#        - First search based on crp_cycle & fec_filing # 
#          - if fec_filing is nil or failed
#             - try using crp_id
#              - if that fails or if there are multiple versions
#                  - try searching by last last name, date and using the fec_filing as the microfilm
#                 - try searching via year, lastname, amount, zip, date
#                    -  if that fails
#                        - write to error log
#          
#        - Create OsMatch
#           * donor_id -> entity1 
#           * recip_id -> entity2
#           * os_donation_id -> OsDonation id from above
#           * relationship_id  
#           * matched_by -> userid for system 
#           * donation_id -> Donation.find_by(relationship_id: ##).id
#        - Update or create reference    
#           * Set reference type to be fec filing
#           * Ensure  correct relationship_id
#           * Update links
# 
#   - After creating all OsDonation/OsMatches
#        * update amount on relationship
#        * update # of fec_filing
