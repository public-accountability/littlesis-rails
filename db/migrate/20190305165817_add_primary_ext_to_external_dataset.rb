class AddPrimaryExtToExternalDataset < ActiveRecord::Migration[5.2]
  def change
    add_column :external_datasets, :primary_ext, :tinyint
  end
end
