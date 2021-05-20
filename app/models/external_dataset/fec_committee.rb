# frozen_string_literal: true

module ExternalDataset
  class FECCommittee < ApplicationRecord
    extend DatasetInterface
    extend FECData
    self.dataset = :fec_committees

    has_many :contributions,
             class_name: 'ExternalDataset::FECContribution',
             foreign_key: 'cmte_id',
             primary_key: 'cmte_id',
             inverse_of: :fec_committee

    belongs_to :candidate, ->(committee) { where(fec_year: committee.fec_year) },
               class_name: 'ExternalDataset::FECCandidate',
               foreign_key: 'cand_id',
               primary_key: 'cand_id',
               optional: true

    belongs_to :external_link,
               -> { where(link_type: :fec_committee) },
               class_name: 'ExternalLink',
               foreign_key: 'cmte_id',
               primary_key: 'link_id',
               optional: true

    has_one :entity, through: :external_link

    def display_name
      "#{cmte_nm} (#{cmte_id})"
    end

    def create_littlesis_entity
      return entity if entity.present?

      Entity.create!(primary_ext: 'Org', name: cmte_nm.titleize).tap do |entity|
        entity.add_extension('PoliticalFundraising')
        entity.external_links.create!(link_type: :fec_committee, link_id: cmte_id)
      end

      reload_entity
    end
  end

end
