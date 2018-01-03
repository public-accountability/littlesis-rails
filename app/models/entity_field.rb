class EntityField < ApplicationRecord
  has_paper_trail only: [:value]

  belongs_to :entity, inverse_of: :entity_fields
  belongs_to :field, inverse_of: :entity_fields
end