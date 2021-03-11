stats = Struct.new(:missing, :found, :already_imported, :new_committees).new
stats.missing = 0
stats.found = 0
stats.already_imported = 0
stats.new_committees = 0

OsMatch.order('random()').limit(1_000).find_each do |os_match|
  fec_trans_id = os_match.os_donation.fectransid.to_i

  fec_contribution = ExternalDataset::FECContribution.find_by(sub_id: fec_trans_id)

  if fec_contribution.nil?
    stats.missing += 1
    next
  elsif FECMatch.exist?(sub_id: fec_trans_id)
  end



  unless
    stats.missing += 1
    next
  else
    stats.found += 1
  end

  if
    stats.already_imported += 1
    next
  end

  unless fec_contribution.fec_committee.entity.present?
    fec_contribution.fec_committee.create_littlesis_entity
    stats.new_committees += 1
  end



  fec_match = FECMatch.create!(sub_id: fec_trans_id, donor_id: os_match.donor_id)



  fec_match.update!(recipient: fec_contribution.fec_committee.entity)

  fec_cand_id = fec_contribution.fec_committee.cand_id

  if fec_cand_id
    candidate = ExternalLink.fec_candidate.find_by(link_id: fec_cand_id)&.entity

    fec_match.update!(candidate: candidate) if candidate
  end
end

Rails.logger.info(stats)
puts stats.to_h


# Relationship.where(description1: 'Campaign Contribution').where('filings > 0').find_each do |relationship|

#   unless relationship.os_matches.exists?
#     stats.no_os_matches += 1
#     next
#   end

#   fec_trans_ids = relationship.os_matches.map(&:os_donation).map(&:fectransid).map(&:to_i)
#   fec_contributions = ExternalDataset::FECContribution.where(sub_id: fec_trans_ids).to_s

#   if fec_contributions.count.zero?
#     stats.no_fec_contributions += 1
#     next
#   else fec_contributions.count != fec_trans_ids.count
#     stats.partial += 1
#   else
#     stats.complete += 1
#   end


#   fec_match = FECMatch.new(relationship: relationship)





# end

# def relationships
#   Relationship.find_by_sql <<~SQL
#     SELECT distinct relationship_id
#     FROM os_matches
#     WHERE relationship_id IS NOT NULL
#   SQL
# end

# relationships.each do |relationship|
#   # Find any ExternalRelationship.fec_contributions that matches
#   relationship.os_matches.map(&:os_donations)
#   r.os_matches.map
# end

# Update Existing Relationship
#
#
# ExternalRelationship.fec_contribution
#            ↓
#       Relationship
#            ↓
# ExternalRelationship.fec_contribution (1 or more)
#            ↓
# ExternalData.
#
# Donor     (entity1)
# Committee (entity2)
#
#
