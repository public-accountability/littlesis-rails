class SfGuardUser < ActiveRecord::Base
  include SingularTable
  include SoftDelete

  has_many :notes, inverse_of: :sf_guard_user, dependent: :destroy

  has_one :user, inverse_of: :sf_guard_user
  has_one :sf_guard_user_profile, inverse_of: :sf_guard_user, foreign_key: "user_id"
  has_many :edited_entities, class_name: "Entity", foreign_key: "last_user_id", inverse_of: :last_user

	has_many :sf_guard_user_groups, foreign_key: "user_id", inverse_of: :sf_guard_user, dependent: :destroy
	has_many :sf_guard_groups, through: :sf_guard_user_group, inverse_of: :sf_guard_users
end