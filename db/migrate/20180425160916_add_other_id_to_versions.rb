class AddOtherIdToVersions < ActiveRecord::Migration[5.1]
  def change
    add_column :versions, :other_id, :bigint
  end
end
