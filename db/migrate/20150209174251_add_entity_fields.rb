class AddEntityFields < ActiveRecord::Migration
  def change
    create_table :fields do |t|
      t.string :name, null: false
      t.string :display_name, null: false
      t.string :type, null: false, default: "string"
      t.index :name, unique: true
    end

    create_table :entity_fields do |t|
      t.references :entity
      t.references :field
      t.string :value, null: false
      t.boolean :is_admin, default: false
      t.index [:entity_id, :field_id], unique: true
    end
  end
end
