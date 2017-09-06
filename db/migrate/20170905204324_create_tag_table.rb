class CreateTagTable < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.boolean :restricted, default: false
      t.string :name, null: false
      t.text :description, null: false

      t.timestamps null: false
    end
    add_index :tags, :name, unique: true
  end
end
