# frozen_string_literal: true

module ExternalDataset
  class FECCandidate < ApplicationRecord
    extend DatasetInterface
    extend FECData
    self.dataset = :fec_candidates
  end
end
