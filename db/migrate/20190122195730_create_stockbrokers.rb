class CreateStockbrokers < ActiveRecord::Migration[5.2]
  def change
    create_table :stockbrokers do |t|
      t.bigint :entity_id, null: false
      t.integer :crd_number

      t.timestamps
    end
    
    add_index :stockbrokers, :entity_id, unique: true
    add_foreign_key :stockbrokers, :entity
    add_index :stockbrokers, :crd_number, unique: true
  end
end
