class AddAssociationDataToVersions < ActiveRecord::Migration
  TEXT_BYTES = 1_073_741_823

  def change
    add_column :versions, :association_data, :text, limit: TEXT_BYTES
  end
end
