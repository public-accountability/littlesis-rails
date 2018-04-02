class AddThumbnailToNetworkMapsTable < ActiveRecord::Migration
  def change
    change_table :network_map do |t|
      t.string :thumbnail
    end
  end
end
