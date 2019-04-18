class AddDatasetKeyToExternalDatasets < ActiveRecord::Migration[5.2]
  def change
    add_column :external_datasets, :dataset_key, :string, null: false
    add_index :external_datasets, %i[name dataset_key], unique: true
  end
end
