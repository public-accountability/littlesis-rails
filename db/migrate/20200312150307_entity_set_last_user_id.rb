class EntitySetLastUserId < ActiveRecord::Migration[6.0]
  def up
  	Entity.each do |entity|
  		user_id = User.find_by(sf_guard_user_id: entity.last_user_id).id
  		entity.update_column!(last_user_id: user_id)
  	end
  end

  def down
  end
end
