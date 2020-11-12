# frozen_string_literal: true

module FEC
  class CandidateCommitteeLinkage < ApplicationRecord
    self.table_name = 'candidate_committee_linkages'
    # belongs_to :candidate, foreign_key: 'CAND_ID'
  end
end
