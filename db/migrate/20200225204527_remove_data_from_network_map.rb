class RemoveDataFromNetworkMap < ActiveRecord::Migration[6.0]
  def change
     remove_column :network_map, :data
  end
end
