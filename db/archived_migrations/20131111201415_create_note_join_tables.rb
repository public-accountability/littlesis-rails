class CreateNoteJoinTables < ActiveRecord::Migration
  def change
    create_table :note_users do |t|
    	t.references :note
    	t.references :user
    end

    create_table :note_entities do |t|
    	t.references :note
    	t.references :entity
    end

    create_table :note_relationships do |t|
    	t.references :note
    	t.references :relationship
    end

    create_table :note_lists do |t|
    	t.references :note
    	t.references :list
    end
  end
end
