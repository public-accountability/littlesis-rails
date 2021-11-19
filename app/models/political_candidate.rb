# frozen_string_literal: true

class PoliticalCandidate < ApplicationRecord
  has_paper_trail on: [:update],
                  meta: { entity1_id: :entity_id }

  belongs_to :entity, inverse_of: :political_candidate

  def fec_candidate_ids
    entity.external_links.fec_candidate.pluck(:link_id)
  end

  def principle_committee_ids
    ExternalDataset.fec_candidates.where(cand_id: fec_candidate_ids).map { |cand| cand.principle_committee.cmte_id }.uniq
  end

  def latest_committee
    ExternalDataset.fec_committees.where(cmte_id: principle_committee_ids).order(fec_year: :desc).first
  end
end
