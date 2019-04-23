class RemoveNameFromExternalDatasets < ActiveRecord::Migration[5.2]
  def change
    remove_index :external_datasets, name: "index_external_datasets_on_name_and_dataset_key"
    remove_column :external_datasets, :name
  end
end
