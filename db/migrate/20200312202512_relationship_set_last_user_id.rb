class RelationshipSetLastUserId < ActiveRecord::Migration[6.0]
  def up
    Relationship.unscoped.find_each do |rel|
      user = User.find_by(sf_guard_user_id: rel.last_user_id)

      if user.nil?
        Rails.logger.warn "Couldn't find User with sf_guard_user_id of #{rel.last_user_id}; setting relationship #{rel.id} last_user_id to 1"
        rel.update_columns(last_user_id: 1)
      else
        rel.update_columns(last_user_id: user.id)
      end
    end
  end

  def down
    Relationship.unscoped.find_each do |rel|
      sf_user_id = User.find(rel.last_user_id)&.sf_guard_user_id || 1
      rel.update_columns(last_user_id: sf_user_id)
    end
  end
end
