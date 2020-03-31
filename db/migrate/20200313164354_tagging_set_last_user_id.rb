class TaggingSetLastUserId < ActiveRecord::Migration[6.0]
  def up
    Tagging.unscoped.find_each do |tagging|
      user = User.find_by(sf_guard_user_id: tagging.last_user_id)

      if user.nil?
        Rails.logger.warn "Couldn't find User with sf_guard_user_id of #{tagging.last_user_id}; setting tagging #{tagging.id} last_user_id to 1"
        user_id = 1
      else
        user_id = user.id
      end

      tagging.update_columns(last_user_id: user_id)
    end
  end

  def down
    Tagging.unscoped.find_each do |tagging|
      sf_user_id = User.find(tagging.last_user_id)&.sf_guard_user_id || 1
      tagging.update_columns(last_user_id: sf_user_id)
    end
  end
end
