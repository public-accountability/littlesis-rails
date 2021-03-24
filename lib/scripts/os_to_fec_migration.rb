stats = { :missing => 0, :already_imported => 0, :new_committees => 0, :errors => 0 }

OsMatch.find_each do |os_match|
  # fec trans id in OsDonation  = sub_id in new fec tables
  fec_trans_id = os_match.os_donation.fectransid.to_i

  fec_contribution = ExternalDataset::FECContribution.find_by(sub_id: fec_trans_id)

  if fec_contribution.nil?
    stats[:missing] += 1
    next
  elsif FECMatch.exists?(sub_id: fec_trans_id)
    stats[:already_imported] += 1
    next
  end

  begin
    ApplicationRecord.transaction do
      unless fec_contribution.fec_committee.entity.present?
        fec_contribution.fec_committee.create_littlesis_entity
        stats[:new_committees] += 1
      end

      fec_match = FECMatch.create!(sub_id: fec_trans_id, donor_id: os_match.donor_id)

      fec_match.update!(recipient: fec_contribution.fec_committee.entity)

      # if the committees is associated with a candidates and the candidate is in LittleSis
      if (fec_cand_id = fec_contribution.fec_committee.cand_id) && (candidate = ExternalLink.fec_candidate.find_by(link_id: fec_cand_id)&.entity)
        fec_match.update!(candidate: candidate)
      end

    rescue => e
      Rails.logger.warn "OsMatch (#{os_match.id}) Error: #{e.message}"
      stats[:errors] += 1
    end
  end
end

Rails.logger.info(stats)
