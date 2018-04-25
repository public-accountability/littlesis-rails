# frozen_string_literal: true

class ListEntity < ApplicationRecord
  self.table_name = 'ls_list_entity'
  include Api::Serializable

  has_paper_trail on: [:create, :destroy],
                  meta: { entity1_id: :entity_id }

  belongs_to :list, inverse_of: :list_entities
  belongs_to :entity, inverse_of: :list_entities

  after_destroy :touch_list

  private

  def touch_list
    list.touch
  end
end
