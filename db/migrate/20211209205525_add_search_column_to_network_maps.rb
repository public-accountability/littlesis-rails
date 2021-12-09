class AddSearchColumnToNetworkMaps < ActiveRecord::Migration[6.1]
  def change
    add_column :network_maps, :search_tsvector, 'tsvector'
    add_index :network_maps, :search_tsvector, using: :gin
  end
end
