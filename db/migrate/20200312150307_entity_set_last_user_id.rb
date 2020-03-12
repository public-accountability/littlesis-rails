class EntitySetLastUserId < ActiveRecord::Migration[6.0]
  def up
    Entity.find_each do |entity|
      user_id = User.find_by(sf_guard_user_id: entity.last_user_id).id
      entity.update_column!(last_user_id: user_id)
    end
  end

  def down
    Entity.find_each do |entity|
      sf_user_id = User.find(entity.last_user_id).sf_guard_user_id
      entity.update_column!(last_user_id: sf_user_id)
    end
  end
end