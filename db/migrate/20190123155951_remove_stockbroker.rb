class RemoveStockbroker < ActiveRecord::Migration[5.2]
  def up
    drop_table :stockbrokers
    ExtensionDefinition.find(41).delete
  end


  def down
    create_table :stockbrokers do |t|
      t.bigint :entity_id, null: false
      t.integer :crd_number

      t.timestamps
    end
    
    add_index :stockbrokers, :entity_id, unique: true
    add_foreign_key :stockbrokers, :entity
    add_index :stockbrokers, :crd_number, unique: true

    ExtensionDefinition
      .create!({
                 name: "Stockbroker",
                 display_name: "Stockbroker",
                 has_fields: true,
                 parent_id: nil,
                 tier: 2,
                 id: 41
               })
    
  end
end
