class AddListSourcesToNetworkMaps < ActiveRecord::Migration
  def change
    change_table :network_map do |t|
      t.boolean :list_sources, default: false, null: false
    end
  end
end
