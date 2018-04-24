class DropTableNoteNetworks < ActiveRecord::Migration[5.1]
  def change
    drop_table :note_networks
  end
end
