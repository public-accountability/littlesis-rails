# frozen_string_literal: true

class ApplicationVersion < ApplicationRecord
  include PaperTrail::VersionConcern
  self.table_name = 'versions'
  # self.abstract_class = true

  after_create :create_edited_entity, if: :entity_edit?

  def entity_edit?
    item_type == 'Entity' || entity1_id.present?
  end

  private

  def create_edited_entity
    EditedEntity.create_from_version(self)
  end
end
