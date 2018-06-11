class CreateExternalLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :external_links do |t|
      t.integer :link_type, null: false, limit: 1, unsigned: true
      t.bigint :entity_id, null: false
      t.string :link_id, null: false

      t.timestamps
    end

    add_index :external_links, :entity_id
    add_index :external_links, [:entity_id, :link_type], unique: true

  end
end
