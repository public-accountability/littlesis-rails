class OsLegacyMatcher
  attr_reader :relationship_id, :filings
  
  def initialize( relationship_id )
    @relationship_id = relationship_id
  end

  def find_filing
    @filings = FecFiling.where(relationship_id: @relationship_id)
  end

  def corresponding_os_donation(f)
    donation = OsDonation.find_by(fectransid: f.fec_filing_id, cycle: f.crp_cycle.to_s)
    if donation.nil?
      # continue searching
    else
      return donation
    end
  end

  
  def match
  end
  
  def fecFiling
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
