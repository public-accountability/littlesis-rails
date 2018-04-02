class CreateTaggings < ActiveRecord::Migration
  def change
    create_table :taggings do |t|
      t.integer :tag_id, null: false
      t.string :tagable_class, null: false
      t.integer :tagable_id, null: false

      t.timestamps null: false
    end
    add_index :taggings, :tag_id
    add_index :taggings, :tagable_class
    add_index :taggings, :tagable_id
  end
end
