class DropGroupTables < ActiveRecord::Migration[5.2]
  def change
    drop_table :groups
    drop_table :group_users
    drop_table :group_lists

    remove_foreign_key :sf_guard_group_list, name: "sf_guard_group_list_ibfk_1"
    remove_foreign_key :sf_guard_group_list, name: "sf_guard_group_list_ibfk_2"
    remove_foreign_key :sf_guard_group_permission, name: "sf_guard_group_permission_ibfk_2"
    remove_foreign_key :sf_guard_group_permission,  name: "sf_guard_group_permission_ibfk_1"
    remove_foreign_key :sf_guard_user_group, name: "sf_guard_user_group_ibfk_2"
    remove_foreign_key :sf_guard_user_group, name: "sf_guard_user_group_ibfk_1"

    drop_table :sf_guard_group
    drop_table :sf_guard_group_list
    drop_table :sf_guard_group_permission
    drop_table :sf_guard_user_group
  end
end
