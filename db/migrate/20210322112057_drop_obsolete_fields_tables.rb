class DropObsoleteFieldsTables < ActiveRecord::Migration[6.1]
  def change
    drop_table :fields
    drop_table :entity_fields
  end
end
