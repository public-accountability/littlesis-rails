class CreateMapAnnotations < ActiveRecord::Migration
  def change
    create_table :map_annotations do |t|
      t.integer :map_id, null: false
      t.integer :order, null: false
      t.string :title
      t.text :description
      t.string :highlighted_entity_ids
      t.string :highlighted_rel_ids
      t.string :highlighted_text_ids
      t.index :map_id
    end
  end
end
