# frozen_string_literal: true

class FECMatch < ApplicationRecord
  # FEC transaction record
  belongs_to :fec_contribution, foreign_key: 'sub_id', primary_key: 'sub_id', class_name: 'ExternalDataset::FECContribution'
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
    if r.exists?
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

  private

  def committee_relationship_attrs
    { category_id: Relationship::DONATION_CATEGORY,
      entity: donor,
      related: recipient,
      description: 'Campaign Contribution' }
  end
end
