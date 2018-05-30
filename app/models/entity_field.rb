# frozen_string_literal: true

class EntityField < ApplicationRecord
  has_paper_trail only: [:value], on: %i[create destroy update]

  belongs_to :entity, inverse_of: :entity_fields
  belongs_to :field, inverse_of: :entity_fields
end
