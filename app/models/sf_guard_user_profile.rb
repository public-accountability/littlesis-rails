class SfGuardUserProfile < ActiveRecord::Base
  include SingularTable	

  has_one :sf_guard_user, inverse_of: :sf_guard_user_profile
  has_one :user, through: :sf_guard_user, inverse_of: :sf_guard_user_profile

  def create_user
		user = new(
			email: email, 
			password: email, 
			password_confirmation: email,
			sf_guard_user_id: user_id 
		)
		user.save
	end
end