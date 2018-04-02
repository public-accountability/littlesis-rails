class AddIsFeaturedToNetworkMap < ActiveRecord::Migration
  def change
    change_table :network_map do |t|
      t.boolean :is_featured, null: false, default: false
    end
  end
end
