class UpdateNetworkMaps < ActiveRecord::Migration
  def up
    change_column :network_map, :entity_ids, :string, limit: 5000
    change_column :network_map, :rel_ids, :string, limit: 5000
  end

  def down
    change_column :network_map, :entity_ids, :string, limit: 1000
    change_column :network_map, :rel_ids, :string, limit: 1000
  end
end
