# frozen_string_literal: true

class CmpEntity < ApplicationRecord
  belongs_to :entity
  enum entity_type: [:org, :person]
  validates :strata, inclusion: { in: (1..5) }, allow_nil: true
end
