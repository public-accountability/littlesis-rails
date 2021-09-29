# frozen_string_literal: true

module ExternalDataset
  class FECCandidate < ApplicationRecord
    extend DatasetInterface
    extend FECData
    self.dataset = :fec_candidates

    belongs_to :principle_committee, ->(cand) { where(fec_year: cand.fec_year) },
               class_name: 'ExternalDataset::FECCommittee',
               foreign_key: 'cand_pcc',
               primary_key: 'cmte_id',
               optional: true # should this be required?

    belongs_to :external_link,
               -> { where(link_type: :fec_candidate) },
               class_name: 'ExternalLink',
               foreign_key: 'cand_id',
               primary_key: 'link_id',
               optional: true

    has_one :entity, through: :external_link

    def create_littlesis_entity
      return entity if entity.present?

      Entity.create!(primary_ext: 'Person', name: NameParser.new(cand_name).to_s).tap do |entity|
        entity.add_extension('PoliticalCandidate')
        entity.external_links.create!(link_type: :fec_candidate, link_id: cand_id)

        Rails.logger.info "Created LittleSis entity\##{entity.id} for FEC Candidate #{id}"
      end

      reload_entity
    end
  end
end
