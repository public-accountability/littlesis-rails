class LsHash < ActiveSupport::HashWithIndifferentAccess
  def with_last_user(user_or_user_id)
    merge(last_user_id: User.derive_last_user_id_from(user_or_user_id))
  end
end
