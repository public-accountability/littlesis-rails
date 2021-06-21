class GovernmentBody < ApplicationRecord
  has_paper_trail on: [:update],
                  meta: { entity1_id: :entity_id }

  belongs_to :entity, inverse_of: :government_body
end
