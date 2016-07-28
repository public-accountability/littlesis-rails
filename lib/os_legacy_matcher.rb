class OsLegacyMatcher
  attr_reader :relationship_id, :filings
  
  def initialize( relationship_id )
    @relationship_id = relationship_id
  end

  def find_filing
    @filings = FecFiling.where(relationship_id: @relationship_id)
  end

  def corresponding_os_donation(f)
    d = OsDonation.find_by(fectransid: f.fec_filing_id, cycle: f.crp_cycle.to_s)
    return d unless d.nil?
    d = OsDonation.find_by(fectransid: f.crp_id, cycle: f.crp_cycle.to_s)
    return d unless d.nil?

    return OsDonation.find_by(
      cycle: f.crp_cycle.to_s, 
      date: f.start_date, 
      microfilm: f.fec_filing_id,
      amount: f.amount)
  end

  def match_all
    find_filing
    @filings.each { |f| match_one(f) }
  end
  
  def match_one(filing)
    donation = corresponding_os_donation(filing)
    if donation.nil?
      no_donation filing
    else
      create_os_match donation
    end
  end

  def create_os_match(donation)
    os_match = OsMatch.new
    os_match.os_donation = donation
    rel = Relationship.find(@relationship_id)
    os_match.relationship = rel
    os_match.donor_id = rel.entity1_id
    os_match.recip_id = rel.entity2_id
    os_match.reference_id = find_reference
    os_match.donation = rel.donation
    os_match.save!
  end

  def find_reference
  end
  
  def no_donation(f)
    printf("** Count not find a match for FecFiling: %s", f.id)
    f = File.new("os_legacy_matcher_error_log.txt", "a")
    f.write("#{@relationship_id},#{f.id}")
  end

end


#
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
#   - After creating all OsDonation
#        * update amount on relationship
#        * update # of fec_filing
# 
