class RemoveLegacyApiTables < ActiveRecord::Migration[6.0]
  def change
    drop_table :api_request
    drop_table :api_user
  end
end
