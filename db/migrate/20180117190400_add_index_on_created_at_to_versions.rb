class AddIndexOnCreatedAtToVersions < ActiveRecord::Migration[5.0]
  def change
    add_index :versions, :created_at, order: :desc
  end
end
