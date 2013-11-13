class SfGuardUserGroup < ActiveRecord::Base
  include SingularTable	

	belongs_to :sf_guard_user, foreign_key: "user_id", inverse_of: :sf_guard_user_groups
	belongs_to :sf_guard_group, foreign_key: "group_id", inverse_of: :sf_guard_user_groups
end