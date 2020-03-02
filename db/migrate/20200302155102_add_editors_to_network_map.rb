class AddEditorsToNetworkMap < ActiveRecord::Migration[6.0]
  def change
    add_column :network_map, :editors, :text
  end
end
