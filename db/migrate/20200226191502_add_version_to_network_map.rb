class AddVersionToNetworkMap < ActiveRecord::Migration[6.0]
  def up
    add_column :network_map, :oligrapher_version, :integer, limit: 1, null: false, default: 2
    NetworkMap.update_all oligrapher_version: 2
  end

  def down
    remove_column :network_map, :oligrapher_version
  end
end
