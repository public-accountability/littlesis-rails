class SfGuardUserProfile < ActiveRecord::Base
  include SingularTable	

  has_one :sf_guard_user, inverse_of: :sf_guard_user_profile
  has_one :user, through: :sf_guard_user, inverse_of: :sf_guard_user_profile

  def create_user_with_email_password
  	User.where(sf_guard_user_id: user_id).first_or_create do |user|
			user.email = email
			user.password = email
			user.password_confirmation = email
			user.sf_guard_user_id = user_id
		end
	end
end