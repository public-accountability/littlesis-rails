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

  after_save :touch_list_and_entity
  after_destroy :touch_list_and_entity

  def self.add_to_list!(list_id:, entity_id:, current_user: nil)
    list = List.find(list_id)
    raise Exceptions::PermissionError unless list.user_can_edit?(current_user)

    find_or_initialize_by(list_id: list.id, entity_id: entity_id).tap do |le|
      le.current_user = current_user
      le.save!
    end
  end

  def self.remove_from_list!(list_entity_id, current_user: nil)
    le = find(list_entity_id)
    le.current_user = current_user
    le.destroy!
  end

  private

  def touch_list_and_entity
    list.touch
    entity.touch_by(current_user)
  end
end
