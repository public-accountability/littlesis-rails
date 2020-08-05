class AddDatasetIndexOnExternalData < ActiveRecord::Migration[6.0]
  def change
    add_index :external_data, :dataset
  end
end
