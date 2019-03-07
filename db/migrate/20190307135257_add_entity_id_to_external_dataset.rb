class AddEntityIdToExternalDataset < ActiveRecord::Migration[5.2]
  def up
    remove_column :external_datasets, :matched
    add_column :external_datasets, :entity_id, :bigint
  end

  def down
    add_column :external_datasets, :matched, :boolean, default: false, null: false
    remove_column :external_datasets, :entity_id
  end
end
