class DropExternalDatasets < ActiveRecord::Migration[6.0]
  def change
    drop_table :external_datasets
  end
end
