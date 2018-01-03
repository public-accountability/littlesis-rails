class SfGuardUserPermission < ApplicationRecord
  include SingularTable

  belongs_to :sf_guard_user, foreign_key: "user_id", inverse_of: :sf_guard_user_permissions
  belongs_to :sf_guard_permission, foreign_key: "permission_id", inverse_of: :sf_guard_user_permissions


  def self.remove_permission(attributes)
    permission = attributes[:permission_id].to_i
    user = attributes[:user_id].to_i
    sql = sanitize_sql_array(["DELETE FROM `sf_guard_user_permission` WHERE `sf_guard_user_permission`.`permission_id` = ? AND `sf_guard_user_permission`.`user_id` = ? LIMIT 1", permission, user]) 
    connection.execute(sql)
  end

end
