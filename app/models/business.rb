# frozen_string_literal: true

class Business < ApplicationRecord
  alias_attribute :assets_under_management, :aum
  belongs_to :entity, inverse_of: :business

  has_paper_trail on: [:update],
                  meta: { entity1_id: :entity_id },
                  versions: { class_name: 'ApplicationVersion' }
end
