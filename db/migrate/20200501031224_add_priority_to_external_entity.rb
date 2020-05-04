class AddPriorityToExternalEntity < ActiveRecord::Migration[6.0]
  def change
    add_column :external_entities, :priority, :integer, :limit => 1, :null => false, default: 0
    add_index :external_entities, :priority
  end
end
