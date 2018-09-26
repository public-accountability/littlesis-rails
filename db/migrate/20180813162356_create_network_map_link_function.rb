require Rails.root.join('lib', 'utility.rb').to_s

class CreateNetworkMapLinkFunction < ActiveRecord::Migration[5.2]
  def up
    Utility.execute_sql_file(
      Rails.root.join('lib', 'sql', 'network_map_link.sql').to_s
    )
  end

  def down
    ApplicationRecord.connection.execute "DROP FUNCTION IF EXISTS network_map_link"
  end
end
