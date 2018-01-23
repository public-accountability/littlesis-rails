class CreateCmpEntities < ActiveRecord::Migration[5.0]
  def change
    create_table :cmp_entities do |t|
      t.bigint :entity_id
      t.integer :cmp_id
      t.integer :entity_type, limit: 1, unsigned: true, null: false

      t.timestamps
    end
    add_index :cmp_entities, :cmp_id, unique: true
    add_index :cmp_entities, :entity_id, unique: true
    add_foreign_key :cmp_entities, :entity, column: 'entity_id'
  end
end
