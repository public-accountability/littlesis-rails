class SfGuardUser < ApplicationRecord
  include SingularTable
  include SoftDelete

  # has_many :notes, foreign_key: "user_id", inverse_of: :sf_guard_user

  has_one :user, inverse_of: :sf_guard_user
  has_one :sf_guard_user_profile, inverse_of: :sf_guard_user, foreign_key: "user_id"
  accepts_nested_attributes_for :sf_guard_user_profile

  has_many :edited_entities, class_name: "Entity", foreign_key: "last_user_id", inverse_of: :last_user

  has_many :sf_guard_user_permissions, foreign_key: "user_id", inverse_of: :sf_guard_user, dependent: :destroy
  has_many :sf_guard_permissions, through: :sf_guard_user_permissions, inverse_of: :sf_guard_users

  has_many :network_maps, foreign_key: 'sf_user_id', inverse_of: :sf_guard_user

	def permissions
		(direct_permissions + group_permissions).uniq
	end

	def direct_permissions
		sf_guard_permissions.pluck(:name).uniq
	end

	def group_permissions
		sf_guard_groups_permissions.pluck(:name).uniq
	end

	def has_permission(name)
		permissions.include?(name)
	end
end
