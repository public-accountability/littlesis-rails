# frozen_string_literal: true

# Class used to retrieve versions and edits for entities
class EntityHistory < RecordHistory
  model_name :entity

  # exclude users: system, cmp-bot, congress-bot
  EXCLUDED_LAST_USERS = [1, 8178, 8270].freeze

  def self.recently_edited_entities(page: 1)
    EditedEntity::Query
      .without_system_users
      .per(10)
      .page(page)
      .preload_entity
      .preload_user
  end

  private

  # str, str -> str
  # SQL statement to extract version for the entity
  # It includes version for models (such as Relationship and Alias)
  # that have been marked as associated with this entity via the entity1_id field
  def versions_sql(select: '*', order: 'ORDER BY created_at DESC')
    <<~SQL
      SELECT #{select}
      FROM versions
      WHERE (item_id = #{entity.id} AND item_type = 'Entity')
         OR (entity1_id = #{entity.id})
         OR (entity2_id = #{entity.id})
      #{order}
    SQL
  end
end
