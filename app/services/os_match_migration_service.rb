# frozen_string_literal: true

# Converts OsMatch to an FECMatch
module OsMatchMigrationService
  # return symbols: missing, already_imported, missing_donor, created, error
  def self.run(os_match)
    # fec trans id in OsDonation  = sub_id in new fec tables
    fec_trans_id = os_match.os_donation.fectransid.to_i
    fec_contribution = ExternalDataset.fec_contributions.find_by(sub_id: fec_trans_id)

    if fec_contribution.nil?
      return :missing
    elsif FECMatch.exists?(sub_id: fec_trans_id)
      return :already_imported
    elsif os_match.donor.nil?
      Rails.logger.warn "OsMatch (#{os_match.id}) is missing a donor"
      return :missing_donor
    end

    begin
      ApplicationRecord.transaction do
        if fec_contribution.fec_committee.entity.nil?
          fec_contribution.fec_committee.create_littlesis_entity
        end

        fec_match = FECMatch.create!(sub_id: fec_contribution.sub_id,
                                     donor: os_match.donor,
                                     recipient: fec_contribution.fec_committee.entity)

        # is the committee associated with a candidate?
        if fec_contribution.fec_committee.cand_id.present?
          # is that candidate connected to a LittleSis entity?
          if (candidate = ExternalLink
                            .fec_candidate
                            .find_by(link_id: fec_contribution.fec_committee.cand_id)&.entity)
            fec_match.update!(candidate: candidate)
          end
        end
      end

      :created
    rescue => e
      Rails.logger.warn "OsMatch (#{os_match.id}) Error: #{e.message}. Line: #{e.backtrace[0]}"
      :error
    end
  end
end
