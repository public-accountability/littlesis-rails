class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string :title, null: false
      t.string :url, null: false
      t.string :snippet
      t.datetime :published_at
      t.string :created_by_user_id, null: false
      t.timestamps
    end

    create_table :article_entities do |t|
      t.integer :article_id, null: false
      t.integer :entity_id, null: false
      t.boolean :is_featured, null: false, default: false
      t.timestamps
    end

    add_index :article_entities, [:entity_id, :article_id], unique: true
    add_index :article_entities, :is_featured
  end
end
