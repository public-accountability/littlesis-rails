class SfGuardGroupPermission < ActiveRecord::Base
	include SingularTable

	belongs_to :sf_guard_group, foreign_key: "group_id", inverse_of: :sf_guard_group_permissions
	belongs_to :sf_guard_permission, foreign_key: "permission_id", inverse_of: :sf_guard_group_permissions
end