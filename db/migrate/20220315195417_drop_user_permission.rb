class DropUserPermission < ActiveRecord::Migration[7.0]
  def change
    drop_table :user_permissions
  end
end
