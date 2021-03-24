# frozen_string_literal: true

class FECMatch < ApplicationRecord
  # FEC transaction record
  belongs_to :fec_contribution,
             foreign_key: 'sub_id',
             primary_key: 'sub_id',
             class_name: 'ExternalDataset::FECContribution',
             inverse_of: :fec_match
  # Entity that donated the money
  belongs_to :donor, foreign_key: 'donor_id', class_name: 'Entity'
  # Entity of committee that received the recipient
  belongs_to :recipient, foreign_key: 'recipient_id', class_name: 'Entity'
  # The associated candidate for the recipient (not all committees will have)
  belongs_to :candidate, foreign_key: 'candidate_id', class_name: 'Entity', optional: true


  # belongs_to :committee_relationship, optional: true, foreign_key: 'committee_relationship_id', class_name: 'Relationship', optional;
  # only contributions to committees associated with candidates will have th
  # belongs_to :politician_relationship,  optional: true

  def committee_relationship
    r = Relationship.find_by(committee_relationship_attrs)
    if r.present?
      r
    else
      Rails.logger.info "Creating new relationship for FECMatch\##{id}"
      Relationship.create!(committee_relationship_attrs)
    end
  end

  def update_committee_relationship
    fec_contributions = OsMatch
                          .includes(:fec_contributions)
                          .where(entity: donor, related: recipient)
                          .map(:fec_contributions)
                          .flatten


    # committee_relationship.update(amount: fec_contributions.map(:amount).inject(:+),  filing: fec_contributions.size)
  end


  def self.migration!
    stats = Struct.new(:created, :missing, :already_imported, :new_committees, :errors).new
    stats.created = 0
    stats.missing = 0
    stats.already_imported = 0
    stats.new_committees= 0
    stats.errors = 0

    OsMatch.where("created_at >= ?", 2.years.ago).order('random()').limit(20_000).find_each do |os_match|
      Rails.logger.debug "Converting OsMatch \##{os_match.id}"
      fec_trans_id = os_match.os_donation.fectransid.to_i

      fec_contribution = ExternalDataset::FECContribution.find_by(sub_id: fec_trans_id)

      if fec_contribution.nil?
        stats.missing += 1
        next
      elsif FECMatch.exists?(sub_id: fec_trans_id)
        stats.already_imported += 1
        next
      end

      begin
        ApplicationRecord.transaction do
          unless fec_contribution.fec_committee.entity.present?
            fec_contribution.fec_committee.create_littlesis_entity
            stats.new_committees += 1
          end

          fec_match = FECMatch.create!(sub_id: fec_trans_id, donor_id: os_match.donor_id)

          fec_match.update!(recipient: fec_contribution.fec_committee.entity)

          # Some committees are associated with candidates
          if (fec_cand_id = fec_contribution.fec_committee.cand_id) && (candidate = ExternalLink.fec_candidate.find_by(link_id: fec_cand_id)&.entity)
            fec_match.update!(candidate: candidate)
          end


          stats.created += 1
        rescue => err
          Rails.logger.warn "OsMatch (#{os_match.id}) Error: #{err.message}"
          stats.errors += 1
        end
      end
    end

    Rails.logger.info(stats)
    puts stats.to_h
  end

  private

  def committee_relationship_attrs
    { category_id: Relationship::DONATION_CATEGORY,
      entity: donor,
      related: recipient,
      description1: 'Campaign Contribution' }
  end
end
