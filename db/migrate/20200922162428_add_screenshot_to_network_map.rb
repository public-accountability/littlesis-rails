class AddScreenshotToNetworkMap < ActiveRecord::Migration[6.0]
  def change
    add_column :network_map, :screenshot, :text, size: :medium
  end
end
