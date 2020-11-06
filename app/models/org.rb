# frozen_string_literal: true

class Org < ApplicationRecord
  include SingularTable

  has_paper_trail on: [:update, :destroy],
                  meta: { entity1_id: :entity_id }

  belongs_to :entity, inverse_of: :org, touch: true

  before_create :set_entity_name

  # [String] of name unique variations
  # OrgName.clean(ealiases + entity name)
  def name_variations
    @name_variations ||= entity
                           .aliases
                           .pluck(:name)
                           .concat([entity.name])
                           .map { |n| OrgName.clean(n) }
                           .uniq
  end

  private

  def set_entity_name
    self.name = entity.name
  end
end
