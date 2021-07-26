# frozen_string_literal: true

class ListEntity < ApplicationRecord
  self.table_name = 'ls_list_entity'
  include Api::Serializable

  has_paper_trail on: [:create, :destroy],
                  meta: {
                    entity1_id: :entity_id,
                    other_id: :list_id
                  }

  belongs_to :list, -> { unscope(where: :is_deleted) }, inverse_of: :list_entities
  belongs_to :entity, inverse_of: :list_entities

  after_save :touch_list_and_entity, :update_list_entity_count
  after_destroy :touch_list_and_entity, :update_list_entity_count

  private

  def touch_list_and_entity
    list.touch
    entity.touch_by(current_user)
  end

  def update_list_entity_count
    list.update!(entity_count: list.list_entities.count)
  end
end
