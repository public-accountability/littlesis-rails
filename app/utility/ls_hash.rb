class LsHash < ActiveSupport::HashWithIndifferentAccess
  def with_last_user(user_id)
    merge(last_user_id: user_id.to_i)
  end
end
