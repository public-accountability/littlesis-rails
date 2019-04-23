class AddIndexOnDatasetKeyAndTypeToExternalDatasets < ActiveRecord::Migration[5.2]
  def change
    add_index :external_datasets, %i[type dataset_key], unique: true
  end
end
