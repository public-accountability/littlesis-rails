class CreateIndexOnEntityIdVersionIdUserIdOnEditedEntities < ActiveRecord::Migration[5.2]
  def change
    add_index :edited_entities, [:entity_id, :version_id, :user_id], unique: true
  end
end
