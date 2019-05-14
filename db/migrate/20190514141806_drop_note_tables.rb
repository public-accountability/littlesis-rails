class DropNoteTables < ActiveRecord::Migration[5.2]
  def change
    drop_table :note
    drop_table :note_entities
    drop_table :note_groups
    drop_table :note_lists
    drop_table :note_relationships
    drop_table :note_users
  end
end
