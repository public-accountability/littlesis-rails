# frozen_string_literal: true

class Business < ApplicationRecord
  include SingularTable

  has_paper_trail on: [:update],
                  meta: { entity1_id: :entity_id }

  belongs_to :entity, inverse_of: :business

  def self.with_crd_number
    where(arel_table[:crd_number].not_eq(nil))
  end
end
