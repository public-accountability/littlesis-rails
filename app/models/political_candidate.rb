# frozen_string_literal: true

class PoliticalCandidate < ApplicationRecord
  has_paper_trail on: [:update],
                  meta: { entity1_id: :entity_id },
                  versions: { class_name: 'ApplicationVersion' }

  belongs_to :entity, inverse_of: :political_candidate

  def fec_candidate_ids
    entity.external_links.fec_candidate.pluck(:link_id)
  end

  def principle_committee_ids
    ExternalDataset.fec_candidates.where(cand_id: fec_candidate_ids).map { |cand| cand.principle_committee.cmte_id }.uniq
  end

  def latest_principle_committee
    ExternalDataset.fec_committees.where(cmte_id: principle_committee_ids).order(fec_year: :desc).first
  end

  def principle_committee(fec_year = 2022)
    ExternalDataset.fec_committees.find_by(cmte_id: principle_committee_ids, fec_year: fec_year)
  end
end
