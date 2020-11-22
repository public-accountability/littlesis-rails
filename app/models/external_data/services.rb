# frozen_string_literal: true

class ExternalData
  module Services
    # Acts on batches

    def self.automatch_fec_contributions
      ExternalRelationship.unmatched.fec_contribution.find_each(&:automatch)
    end

    def self.synchronize_fec_candidate_relationships
      ExternalRelationship.fec_contribution.find_each(&:synchronize_donor_candidate_relationship)
    end

    def self.create_fec_donors
      ExternalData.fec_contribution.find_each(&:create_donor_from_self)
      ExternalData.fec_donor.find_each(&:update_fec_donor_data!)
    end

    # Acts on individual models

    # Creates or updates the relationship between the donor and the candidate.
    # This relationship is composed of one or more other relationships between
    # the donor and the committee which accepted the donation.
    # input: ExternalRelationship.fec_contribution
    def self.synchronize_donor_candidate_relationship(external_relationship)
      cand_id = external_relationship.associated_fec_committee&.data&.fetch('CAND_ID', nil)
      # not all comittees are associated with candidates
      return if cand_id.blank?

      littlesis_candidate = ExternalData.fec_candidate.find_by(dataset_id: cand_id)&.external_entity&.entity

      if littlesis_candidate.nil?
        Rails.logger.info "ExternalData.fec_candidate with candidate id #{cand_id} is not yet matched"
        return
      end

      relationship = Relationship.find_or_create_by!(category_id: Relationship::DONATION_CATEGORY,
                                                     entity: external_relationship.entity1,
                                                     related: littlesis_candidate,
                                                     description1: 'Campaign Contribution')

      relationship.update!(amount: external_relationship.relationship.amount,
                           start_date: external_relationship.relationship.start_date,
                           end_date: external_relationship.relationship.end_date)
    end
  end
end
