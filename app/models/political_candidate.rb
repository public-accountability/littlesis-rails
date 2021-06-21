class PoliticalCandidate < ApplicationRecord
  has_paper_trail on: [:update],
                  meta: { entity1_id: :entity_id }

  belongs_to :entity, inverse_of: :political_candidate

  def fec_candidate_ids
    entity.external_links.fec_candidate.pluck(:link_id)
  end
end
