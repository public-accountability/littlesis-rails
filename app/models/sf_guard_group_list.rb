class SfGuardGroupList < ActiveRecord::Base
  include SingularTable	

  belongs_to :sf_guard_group, foreign_key: "group_id", inverse_of: :sf_guard_group_lists
  belongs_to :list, inverse_of: :sf_guard_group_lists

	def nonguard_group_id
		g = Group.select(:id).find_by(slug: sf_guard_group.name)
		return nil if g.nil?
		g.id
	end

	def create_group_list
		GroupList.where(group_id: nonguard_group_id, list_id: list_id).first_or_create
	end
end