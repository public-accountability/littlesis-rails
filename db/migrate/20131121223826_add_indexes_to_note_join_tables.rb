class AddIndexesToNoteJoinTables < ActiveRecord::Migration
  def change
  	add_index :note_users, :note_id
  	add_index :note_users, :user_id

  	add_index :note_entities, :note_id
  	add_index :note_entities, :entity_id

  	add_index :note_relationships, :note_id
  	add_index :note_relationships, :relationship_id

  	add_index :note_lists, :note_id
  	add_index :note_lists, :list_id

  	add_index :note_networks, :note_id
  	add_index :note_networks, :network_id

  	add_index :note_groups, :note_id
  	add_index :note_groups, :group_id
  end
end
