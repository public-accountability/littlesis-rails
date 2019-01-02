class CreateEditedEntities < ActiveRecord::Migration[5.2]
  def change
    create_table :edited_entities do |t|
      t.integer :user_id
      t.integer :version_id, null: false
      t.bigint :entity_id, null: false
      t.datetime :created_at, null: false
    end
  end
end
