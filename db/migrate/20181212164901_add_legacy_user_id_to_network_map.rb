class AddLegacyUserIdToNetworkMap < ActiveRecord::Migration[5.2]
  def up
    add_column :network_map, :sf_user_id, :bigint
    ApplicationRecord.execute_sql <<-SQL
      UPDATE network_map
      SET sf_user_id = user_id
    SQL
  end

  def down
    remove_column :network_map, :sf_user_id
  end
end
