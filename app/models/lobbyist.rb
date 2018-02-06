class Lobbyist < ApplicationRecord
  include SingularTable

  has_paper_trail on: [:update],
                  meta: { entity1_id: :entity_id }

  belongs_to :entity, inverse_of: :lobbyist
end
