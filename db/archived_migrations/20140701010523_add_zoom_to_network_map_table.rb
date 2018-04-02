class AddZoomToNetworkMapTable < ActiveRecord::Migration
  def change
    change_table :network_map do |t|
      t.string :zoom, null: false, default: '1'
    end
  end
end
