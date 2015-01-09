class AlterNetworkMapTable < ActiveRecord::Migration
  def up
    change_column :network_map, :entity_ids, :string, limit: 1000
    change_column :network_map, :rel_ids, :string, limit: 1000
  end

  def down
    change_column :network_map, :entity_ids, :string, limit: 200
    change_column :network_map, :rel_ids, :string, limit: 200
  end
end
