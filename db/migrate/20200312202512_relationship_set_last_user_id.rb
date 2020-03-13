class RelationshipSetLastUserId < ActiveRecord::Migration[6.0]
  def up
    Relationship.find_each do |rel|
      user = User.find_by(sf_guard_user_id: entity.last_user_id)

      if user.nil?
        Rails.logger.warn "Couldn't find User with sf_guard_user_id of #{entity.last_user_id}; setting entity #{entity.id} last_user_id to 1"
        user_id = 1
      else
        user_id = user.id
      end

      rel.update_columns(last_user_id: user_id)
    end
  end

  def down
    Relationship.find_each do |rel|
      sf_user_id = User.find(rel.last_user_id)&.sf_guard_user_id || 1
      rel.update_columns(last_user_id: sf_user_id)
    end
  end
end
