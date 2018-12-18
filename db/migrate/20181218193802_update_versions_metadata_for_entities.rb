class UpdateVersionsMetadataForEntities < ActiveRecord::Migration[5.2]
  def up
    ApplicationRecord.execute_sql <<-SQL
      UPDATE versions
      SET entity1_id = item_id
      WHERE item_type = 'Entity'
    SQL
  end

  def down
    ApplicationRecord.execute_sql <<-SQL
      UPDATE versions
      SET entity1_id = NULL
      WHERE item_type = 'Entity'
    SQL
  end
end
