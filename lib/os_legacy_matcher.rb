module OsLegacyMatcher

  def OsLegacyMatcher.match
  end

end


#
#  for each donation relationship
#    - get fecFillings
#      - find corresponding OsDonation
#        - First search based on crp_cycle & fec_filing # 
#          - if fec_filing is nil
#             - try using crp_id
#              - if that fails
#                 - try searching via year, lastname, amount, zip, date
#                    -  if that fails
#                        - write to error log
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
