class AddOligrapherDataToNetworkMap < ActiveRecord::Migration
  def change
    change_table :network_map do |t|
      t.text :graph_data, limit: 262144
      t.text :annotations_data
      t.integer :annotations_count, null: false, default: 0
    end
  end
end
