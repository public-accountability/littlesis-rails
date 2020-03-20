class UserUpdateCreatedAtUsingSfGuardUser < ActiveRecord::Migration[6.0]
  def change
  	User.unscoped.find_each do |user|
  		if user.sf_guard_user and user.sf_guard_user.created_at < user.created_at
  			puts user.sf_guard_user.created_at
	  	end
  	end
  end
end