class RemoveTitleFromImage < ActiveRecord::Migration[5.2]
  def up
    ApplicationRecord.execute_sql <<-SQL
      UPDATE image
      SET caption = title
      WHERE caption IS NULL
    SQL

    ApplicationRecord.execute_sql <<-SQL
      UPDATE image
      SET caption = CONCAT(title, " | ", caption)
      WHERE caption IS NOT NULL
    SQL

    remove_column :image, :title
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
