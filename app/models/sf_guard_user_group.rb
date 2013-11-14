class SfGuardUserGroup < ActiveRecord::Base
  include SingularTable	

	belongs_to :sf_guard_user, foreign_key: "user_id", inverse_of: :sf_guard_user_groups
	belongs_to :sf_guard_group, foreign_key: "group_id", inverse_of: :sf_guard_user_groups

	def create_group_user
		return nil if sf_guard_group.nil? or sf_guard_group.group.nil?
		return nil if sf_guard_user.nil? or sf_guard_user.user.nil?

		GroupUser.where(
			group_id: sf_guard_group.group.id, 
			user_id: sf_guard_user.user.id,
			is_admin: is_owner || false
		).first_or_create
	end
end