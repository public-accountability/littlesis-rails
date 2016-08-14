class CreateOsCommittees < ActiveRecord::Migration
  def change
    create_table :os_committees do |t|
      t.string :cycle, limit: 4, null: false
      t.string :cmte_id, null: false
      t.string :name
      t.string :affiliate
      t.string :ultorg
      t.string :recipid
      t.string :recipcode, limit: 2
      t.string :feccandid
      t.string :party, limit: 1
      t.string :primcode, limit: 5
      t.string :source
      t.boolean :sensitive
      t.boolean :foreign
      t.boolean :active_in_cycle

      t.timestamps
    end
    
    add_index :os_committees, :cmte_id
    add_index :os_committees, :recipid
    add_index :os_committees, [:cmte_id, :cycle]
  end
end
