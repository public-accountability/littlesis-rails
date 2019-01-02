class CreateEditedEntities < ActiveRecord::Migration[5.2]
  def change
    create_table :edited_entities do |t|
      t.integer :user_id
      t.integer :version_id, null: false
      t.bigint :entity_id, null: false
      t.datetime :created_at, null: false

      t.index [:entity_id, :version_id], unique: true
      t.index :created_at, order: { created_at: :desc }
    end
  end
end
