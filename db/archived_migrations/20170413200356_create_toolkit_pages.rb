class CreateToolkitPages < ActiveRecord::Migration
  def change
    create_table :toolkit_pages do |t|
      t.string :name, null: false
      t.string :title
      t.text :markdown, limit: 16.megabytes - 1
      t.integer :last_user_id

      t.timestamps null: false
    end
    add_index :toolkit_pages, :name, unique: true
  end
end
