# frozen_string_literal: true

# FECMatch connects a ExternalDataset::FECContribution with up to 3 Entities:
# a donor (Person), committee (Org), and candidate (Person).
#
# This can be created with only two associations: an FECContribution and Entity (donor),
# in which it will use the FEC data to find existing LittleSis enities for the comittee and candidate,
# and will create those if none are found.
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

  belongs_to :committee_relationship, class_name: 'Relationship'
  belongs_to :candidate_relationship, class_name: 'Relationship', optional: true

  before_create :find_or_create_recipient,
                :find_or_create_candidate,
                :find_or_create_committee_relationship,
                :find_or_create_candidate_relationship

  after_create  :update_committee_relationship, :update_candidate_relationship
  after_destroy :cleanup_relationships

  # All FEC contributions between Donor & Recipient
  def committee_contributions
    FECMatch
      .includes(:fec_contribution)
      .where(donor: donor, recipient: recipient)
      .map(&:fec_contribution)
      .sort_by(&:date)
  end

  # All FEC contributions between Donor & Candidate
  def candidate_contributions
    return if candidate.nil?

    FECMatch
      .includes(:fec_contribution)
      .where(donor: donor, candidate: candidate)
      .map(&:fec_contribution)
      .sort_by(&:date)
  end

  def update_committee_relationship
    contributions = committee_contributions
    committee_relationship.update!(relationship_attrs_from_contributions(contributions))
    contributions.map(&:reference_attributes).each do |attrs|
      committee_relationship.add_reference(attrs).save
    end
  end

  def update_candidate_relationship
    return unless candidate_relationship

    contributions = candidate_contributions
    candidate_relationship.update!(relationship_attrs_from_contributions(contributions))

    contributions.map(&:reference_attributes).each do |attrs|
      candidate_relationship.add_reference(attrs).save
    end
  end

  private

  def find_or_create_committee_relationship
    return if committee_relationship.present?

    found_committee_r = Relationship.find_by(committee_relationship_attrs)

    if found_committee_r.present?
      self.committee_relationship = found_committee_r
    else
      log_debug "Creating Committee Relationship: #{committee_relationship_attrs}"
      create_committee_relationship!(committee_relationship_attrs).tap do |r|
        r.add_reference(fec_contribution.reference_attributes).save!
      end
    end
  end

  def find_or_create_candidate_relationship
    return if candidate_relationship.present? || candidate.nil?

    found_candidate_r = Relationship.find_by(candidate_relationship_attrs)

    if found_candidate_r.present?
      # maybe add reference to existing relationship here?
      self.candidate_relationship = found_candidate_r
    else
      log_debug "Creating Candidate Relationship: #{candidate_relationship_attrs}"
      create_candidate_relationship!(candidate_relationship_attrs).tap do |r|
        r.add_reference(fec_contribution.reference_attributes).save!
      end
    end
  end

  def find_or_create_recipient
    return if recipient.present?

    self.recipient = fec_contribution.fec_committee.create_littlesis_entity
  end

  def find_or_create_candidate
    return if candidate.present? || fec_contribution.fec_committee.candidate.nil?

    self.candidate = fec_contribution.fec_committee.candidate.create_littlesis_entity
  end

  # After a match is removed, the relationships are removed if there are no more remaining
  def cleanup_relationships
    if committee_contributions.present?
      update_committee_relationship
    else
      committee_relationship.soft_delete
    end

    if candidate_contributions.present?
      update_candidate_relationship
    else
      candidate_relationship&.soft_delete
    end
  end

  # attribute helpers

  def relationship_attrs_from_contributions(contributions)
    {
      amount: contributions.sum(&:transaction_amt),
      start_date: contributions.first.date,
      end_date: contributions.last.date,
      filings: contributions.size
    }
  end

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

  def log_debug(msg)
    Rails.logger.debug { "[FECMatch] #{msg}" }
  end
end
