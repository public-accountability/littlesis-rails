class AddTypeToExternalDatasets < ActiveRecord::Migration[5.2]
  def change
    add_column :external_datasets, :type, :string
    add_index :external_datasets, :type
  end
end
