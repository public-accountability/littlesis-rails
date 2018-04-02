class AddMissingIndexes < ActiveRecord::Migration
  def change
  	add_index :group_lists, [:group_id, :list_id], unique: true
  	add_index :group_lists, :list_id

  	add_index :group_users, [:group_id, :user_id], unique: true
  	add_index :group_users, :user_id

  	add_index :groups, :campaign_id

  	add_index :note, :new_user_id
  	add_index :note, :sf_guard_user_id

  	# single-column index no longer needed with new two-column index
  	remove_index :note_entities, column: :note_id
  	add_index :note_entities, [:note_id, :entity_id], unique: true

  	# single-column index no longer needed with new two-column index
  	remove_index :note_groups, column: :note_id
  	add_index :note_groups, [:note_id, :group_id], unique: true

  	# single-column index no longer needed with new two-column index
  	remove_index :note_lists, column: :note_id
  	add_index :note_lists, [:note_id, :list_id], unique: true

  	# single-column index no longer needed with new two-column index
  	remove_index :note_networks, column: :note_id
  	add_index :note_networks, [:note_id, :network_id], unique: true

  	# single-column index no longer needed with new two-column index
  	remove_index :note_relationships, column: :note_id
  	add_index :note_relationships, [:note_id, :relationship_id], unique: true

  	# single-column index no longer needed with new two-column index
  	remove_index :note_users, column: :note_id
  	add_index :note_users, [:note_id, :user_id], unique: true

  	add_index :sf_guard_group, :display_name

  	add_index :users, :username, unique: true
  end
end
