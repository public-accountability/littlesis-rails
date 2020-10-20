class CreateLocations < ActiveRecord::Migration[6.0]
  def change
    create_table :locations do |t|
      t.text :city
      t.text :country
      t.text :subregion
      t.integer :region, limit: 1
      t.decimal :lat
      t.decimal :lng
      t.bigint :entity_id

      t.timestamps
    end
    add_index :locations, :region
    add_index :locations, :entity_id
  end
end
