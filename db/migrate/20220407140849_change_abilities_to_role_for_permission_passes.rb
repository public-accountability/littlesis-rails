class ChangeAbilitiesToRoleForPermissionPasses < ActiveRecord::Migration[7.0]
  def change
    remove_column :permission_passes, :abilities, :text
    add_column :permission_passes, :role, :smallint, null: false
  end
end
