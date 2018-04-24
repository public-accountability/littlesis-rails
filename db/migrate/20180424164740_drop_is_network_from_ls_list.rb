class DropIsNetworkFromLsList < ActiveRecord::Migration[5.1]
  def change
    remove_column :ls_list, :is_network
  end
end
