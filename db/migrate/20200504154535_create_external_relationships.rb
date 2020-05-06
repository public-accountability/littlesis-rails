class CreateExternalRelationships < ActiveRecord::Migration[6.0]
  def change
    create_table :external_relationships do |t|
      t.bigint :external_data_id, null: false
      t.bigint :relationship_id
      t.integer :dataset, limit: 1, null: false

      t.timestamps
    end

    add_foreign_key :external_relationships, :relationship, column: 'relationship_id', on_delete: :nullify
    add_foreign_key :external_relationships, :external_data, column: 'external_data_id', on_delete: :cascade
  end
end
