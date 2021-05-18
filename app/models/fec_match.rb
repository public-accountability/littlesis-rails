# frozen_string_literal: true

class FECMatch < ApplicationRecord
  # FEC transaction record
  belongs_to :fec_contribution,
             foreign_key: 'sub_id',
             primary_key: 'sub_id',
             class_name: 'ExternalDataset::FECContribution',
             inverse_of: :fec_match

  # Entity that donated the money
  belongs_to :donor, class_name: 'Entity'
  # Entity of committee that received the recipient
  belongs_to :recipient, class_name: 'Entity'
  # The associated candidate for the recipient (not all committees will have one)
  belongs_to :candidate, class_name: 'Entity', optional: true

  after_create do
    create_committee_relationship
    update_committee_relationship
    create_candidate_relationship
    update_candidate_relationship
  end

  def committee_relationship
    Relationship.find_by(committee_relationship_attrs)
  end

  def create_committee_relationship
    unless committee_relationship
      Rails.logger.debug "Creating relationship: #{committee_relationship_attrs}"
      Relationship.create!(committee_relationship_attrs).tap do |r|
        r.add_reference(fec_contribution.reference_attributes).save!
      end
    end
  end

  def update_committee_relationship
    contributions = FECMatch
                      .includes(:fec_contribution)
                      .where(donor: donor, recipient: recipient)
                      .map(&:fec_contribution)
                      .sort_by(&:date)

    committee_relationship.update!(amount: contributions.map(&:amount).sum,
                                   start_date: contributions.first.date,
                                   end_date: contributions.last.date,
                                   filings: contributions.size)

    contributions.map(&:reference_attributes).each do |attrs|
      committee_relationship.add_reference(attrs).save
    end
  end

  def candidate_relationship
    return if candidate.nil?

    Relationship.find_by(candidate_relationship_attrs)
  end

  def create_candidate_relationship
    if candidate.present? && candidate_relationship.nil?
      Rails.logger.debug "Creating relationship: #{candidate_relationship_attrs}"
      Relationship.create!(candidate_relationship_attrs).tap do |r|
        r.add_reference(fec_contribution.reference_attributes).save!
      end
    end
  end

  def update_candidate_relationship
    return unless candidate_relationship

    contributions = FECMatch
                      .includes(:fec_contribution)
                      .where(donor: donor, candidate: candidate)
                      .map(&:fec_contribution)
                      .sort_by(&:date)

    candidate_relationship.update!(amount: contributions.map(&:amount).sum,
                                   start_date: contributions.first.date,
                                   end_date: contributions.last.date,
                                   filings: contributions.size)

    contributions.map(&:reference_attributes).each do |attrs|
      candidate_relationship.add_reference(attrs).save
    end
  end

  def self.test_migration!
    migration!(proc do |x|
                 x.where('created_at >= ?', 2.years.ago).order('random()').limit(20_000)
               end)
  end

  def self.migration!(scope = nil)
    raise Exceptions::LittleSisError, "do not run on production yet" if Rails.env.production?

    stats = { missing: 0, already_imported: 0, missing_donor: 0, new_committees: 0, errors: 0, created: 0 }

    os_match_relation = if scope.respond_to?(:call)
                          scope.call(OsMatch.all)
                        else
                          OsMatch.all
                        end

    os_match_relation.find_each do |os_match|
      # fec trans id in OsDonation  = sub_id in new fec tables
      fec_trans_id = os_match.os_donation.fectransid.to_i
      fec_contribution = ExternalDataset::FECContribution.find_by(sub_id: fec_trans_id)

      if fec_contribution.nil?
        stats[:missing] += 1
        next
      elsif FECMatch.exists?(sub_id: fec_trans_id)
        stats[:already_imported] += 1
        next
      elsif os_match.donor.nil?
        Rails.logger.warn "OsMatch (#{os_match.id}) is missing a donor"
        stats[:missing_donor] += 1
        next
      end

      begin
        ApplicationRecord.transaction do
          if fec_contribution.fec_committee.entity.nil?
            fec_contribution.fec_committee.create_littlesis_entity
            stats[:new_committees] += 1
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

          stats[:created] += 1
        end
      rescue => e
        Rails.logger.warn "OsMatch (#{os_match.id}) Error: #{e.message}. Line: #{e.backtrace[0]}"
        stats[:errors] += 1
      end
    end

    Rails.logger.info(stats)
  end

  private

  def committee_relationship_attrs
    { category_id: Relationship::DONATION_CATEGORY,
      entity: donor,
      related: recipient,
      description1: 'Campaign Contribution' }
  end

  def candidate_relationship_attrs
    { category_id: Relationship::DONATION_CATEGORY,
      entity: donor,
      related: candidate,
      description1: 'Campaign Contribution' }
  end
end
