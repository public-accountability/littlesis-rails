class SfGuardGroup < ActiveRecord::Base
  include SingularTable	

	has_many :sf_guard_user_groups, foreign_key: "group_id", inverse_of: :sf_guard_group, dependent: :destroy
	has_many :sf_guard_users, through: :sf_guard_user_groups, inverse_of: :sf_guard_groups

	has_many :sf_guard_group_lists, foreign_key: "group_id", inverse_of: :sf_guard_group, dependent: :destroy
	has_many :lists, through: :sf_guard_group_lists, inverse_of: :sf_guard_groups

	has_many :sf_guard_group_permissions, foreign_key: "group_id", inverse_of: :sf_guard_group, dependent: :destroy
	has_many :sf_guard_permissions, through: :sf_guard_group_permissions, inverse_of: :sf_guard_groups

	scope :working, -> { where(is_working: true) }

	def create_group
		Group.where(slug: name).first_or_create do |group|
			group.slug = name
			group.name = display_name
			group.tagline = blurb
			group.description = HTMLEntities.new.decode(description)
			group.is_private = is_private
			group.default_network_id = home_network_id
			group.created_at = created_at
			group.updated_at = updated_at
		end
	end

	def group
		Group.find_by(slug: name)
	end
end