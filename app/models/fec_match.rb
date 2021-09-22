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

  def self.migration!
    raise Exceptions::LittleSisError, "do not run on production yet" if Rails.env.production?

    stats = { missing: 0, already_imported: 0, missing_donor: 0, error: 0, created: 0 }

    enumerator = if Rails.env.development?
                   OsMatch.joins(:os_donation).where("os_donations.cycle = '2012'").order('random()').limit(100).each
                 else
                   OsMatch.all.find_each
                 end

    enumerator.each do |os_match|
      result = OsMatchMigrationService.run(os_match)
      stats[result] += 1
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
