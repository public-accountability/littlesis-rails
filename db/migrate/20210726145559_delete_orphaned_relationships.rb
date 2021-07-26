class DeleteOrphanedRelationships < ActiveRecord::Migration[6.1]
  def up
    Relationship
      .joins('JOIN entities ON entities.id = relationships.entity1_id')
      .where(entities: {is_deleted: true})
      .where(relationships: {is_deleted: false})
      .update_all(is_deleted: true)

    Relationship
      .joins('JOIN entities ON entities.id = relationships.entity2_id')
      .where(entities: {is_deleted: true})
      .where(relationships: {is_deleted: false})
      .update_all(is_deleted: true)
  end
end
