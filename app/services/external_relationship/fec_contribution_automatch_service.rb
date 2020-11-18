# frozen_string_literal: true

class ExternalRelationship
  class FECContributionAutomatchService
    def self.run
      ExternalLink.fec_committee.pluck(:link_id).each do |committee_id|
        ExternalData
          .includes(:external_relationship)
          .fec_contribution.where("JSON_VALUE(data, '$.CMTE_ID') = ?", committee_id)
          .each { |ed| ed.external_relationship.automatch }
      end
    end
  end
end
