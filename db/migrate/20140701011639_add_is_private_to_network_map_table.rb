class AddIsPrivateToNetworkMapTable < ActiveRecord::Migration
  def change
    change_table :network_map do |t|
      t.boolean :is_private, null: false, default: false
    end
  end
end
