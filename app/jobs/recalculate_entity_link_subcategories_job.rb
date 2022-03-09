# frozen_string_literal: true

class RecalculateEntityLinkSubcategoriesJob < ApplicationJob
  discard_on ActiveRecord::RecordNotFound

  def perform(entity_id)
    Entity.find(entity_id).relationships.each do |relationship|
      relationship.links.each(&:recalculate_subcategory)
    end
  end
end
