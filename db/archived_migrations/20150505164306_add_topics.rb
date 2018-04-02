class AddTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.boolean :is_deleted, default: false, null: false
      t.timestamps
      t.index :name, unique: true
      t.index :slug, unique: true
    end

    create_table :topic_lists do |t|
      t.references :topic
      t.references :list
      t.index [:topic_id, :list_id], unique: true
    end
  end
end
