class PublicCompany < ApplicationRecord
  include SingularTable

  has_paper_trail on: [:update],
                  meta: { entity1_id: :entity_id }

  belongs_to :entity, inverse_of: :public_company
  validates :ticker, length: { maximum: 10 }
end
