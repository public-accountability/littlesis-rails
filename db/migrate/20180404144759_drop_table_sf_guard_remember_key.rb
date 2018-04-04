class DropTableSfGuardRememberKey < ActiveRecord::Migration[5.1]
  def change
    drop_table :sf_guard_remember_key
  end
end
