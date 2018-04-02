class AlterSessionsDataColumn < ActiveRecord::Migration
  def up
    change_column :sessions, :data, :text, limit: 655360
  end

  def down
    change_column :sessions, :data, :text, limit: 65536
  end
end
