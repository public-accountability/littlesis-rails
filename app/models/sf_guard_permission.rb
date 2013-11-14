class SfGuardPermission < ActiveRecord::Base
	include SingularTable

	has_many :sf_guard_user_permissions, foreign_key: "permission_id", inverse_of: :sf_guard_permission, dependent: :destroy
	has_many :sf_guard_users, through: :sf_guard_user_permissions, inverse_of: :sf_guard_permissions

	has_many :sf_guard_group_permissions, foreign_key: "permission_id", inverse_of: :sf_guard_permission, dependent: :destroy
	has_many :sf_guard_groups, through: :sf_guard_group_permissions, inverse_of: :sf_guard_permissions
end