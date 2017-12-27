class PoliticalCandidate < ApplicationRecord
  include SingularTable

  belongs_to :entity, inverse_of: :political_candidate
end