class SfGuardUserPermission < ActiveRecord::Base
	include SingularTable

	belongs_to :sf_guard_user, foreign_key: "user_id", inverse_of: :sf_guard_user_permissions
	belongs_to :sf_guard_permission, foreign_key: "permission_id", inverse_of: :sf_guard_user_permissions
end