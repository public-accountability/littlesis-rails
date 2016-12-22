class AddIsCloneableToNetworkMap < ActiveRecord::Migration
  def change
    add_column :network_map, :is_cloneable, :boolean, default: true, null: false
  end
end
