class RemoveSfUserIdFromNetworkMap < ActiveRecord::Migration[6.0]
  def change
    remove_column :network_map, :sf_user_id
  end
end
