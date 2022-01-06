# frozen_string_literal: true

class CmpEntity < ApplicationRecord
  belongs_to :entity, inverse_of: :cmp_entity
  enum entity_type: [:org, :person]
  validates :strata, inclusion: { in: (1..10) }, allow_nil: true

  has_paper_trail versions: { class_name: 'ApplicationVersion' }

  def self.in_strata
    where.not(strata: nil)
  end

  def self.core_sample
    where(strata: 1)
  end
end
