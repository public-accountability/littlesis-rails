class ListSetLastUserId < ActiveRecord::Migration[6.0]
  def up
    List.unscoped.find_each do |list|
      user = User.find_by(sf_guard_user_id: list.last_user_id)

      if user.nil?
        Rails.logger.warn "Couldn't find User with sf_guard_user_id of #{list.last_user_id}; setting list #{list.id} last_user_id to 1"
        user_id = 1
      else
        user_id = user.id
      end

      user_id = 1 if user_id.nil?

      list.update_columns(last_user_id: user_id)
    end

    # make sure all last_user_ids are set to actual user ids
    user_ids = User.all.map(&:id).uniq
    List.unscoped
          .where.not(last_user_id: user_ids)
          .update_all(last_user_id: 1)
  end

  def down
    List.unscoped.find_each do |list|
      sf_user_id = User.find(list.last_user_id)&.sf_guard_user_id || 1
      list.update_columns(last_user_id: sf_user_id)
    end
  end
end