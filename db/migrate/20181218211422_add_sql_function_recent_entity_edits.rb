require Rails.root.join('lib', 'utility.rb').to_s

class AddSqlFunctionRecentEntityEdits < ActiveRecord::Migration[5.2]
  def up
    Utility.execute_sql_file Rails.root.join('lib', 'sql', 'recent_entity_edits.sql').to_s
  end

  def down
    ApplicationRecord.connection.execute "DROP FUNCTION IF EXISTS recent_entity_edits"
  end
end
