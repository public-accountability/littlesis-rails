class RemoveLegacyOligrapherFields < ActiveRecord::Migration[6.1]
  def change
    remove_column :network_maps, :oligrapher_version
    remove_column :network_maps, :annotations_count
    remove_column :network_maps, :screenshot
    remove_column :network_maps, :thumbnail
  end
end
