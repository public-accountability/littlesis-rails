class CreateNoteNetworks < ActiveRecord::Migration
  def change
    create_table :note_networks do |t|
    	t.references :note
    	t.references :network
    end
  end
end
