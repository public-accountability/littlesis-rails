class CreateQueues < ActiveRecord::Migration
  def change
    create_table :queue_entities do |t|
      t.string :queue, null: false
      t.references :entity
      t.references :user
      t.boolean :is_skipped, null: false, default: false
      t.timestamps
    end

    add_index :queue_entities, [:queue, :entity_id], unique: true
  end
end
