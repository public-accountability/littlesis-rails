class CreateNoteGroups < ActiveRecord::Migration
  def change
    create_table :note_groups do |t|
    	t.references :note
    	t.references :group
    end
  end
end
