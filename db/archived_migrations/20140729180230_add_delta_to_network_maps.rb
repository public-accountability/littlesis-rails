class AddDeltaToNetworkMaps < ActiveRecord::Migration
  def change
    change_table :network_map do |t|
      t.boolean :delta, default: true, null: false
      t.index :delta
      t.text :index_data, limit: 2147483647
    end
  end
end
