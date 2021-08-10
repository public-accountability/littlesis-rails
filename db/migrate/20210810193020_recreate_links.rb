class RecreateLinks < ActiveRecord::Migration[6.1]
  def change
    create_table :links do |t|
      t.integer :entity1_id, null: false
      t.integer :entity2_id, null: false
      t.integer :category_id, null: false
      t.belongs_to :relationship, null: false, foreign_key: true
      t.boolean :is_reverse, null: false

      t.index :entity1_id
      t.index :entity2_id
    end

    add_foreign_key :links, :entities, column: :entity1_id
    add_foreign_key :links, :entities, column: :entity2_id
    add_foreign_key :links, :relationship_categories, column: :category_id
  end
end
