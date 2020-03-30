class EntitySetLastUserId < ActiveRecord::Migration[6.0]
  def up
    Entity.unscoped.find_each do |entity|
      user = User.find_by(sf_guard_user_id: entity.last_user_id)

      if user.nil?
        Rails.logger.warn "Couldn't find User with sf_guard_user_id of #{entity.last_user_id}; setting entity #{entity.id} last_user_id to 1"
        entity.update_columns(last_user_id: 1)
      else
        entity.update_columns(last_user_id: user.id)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
