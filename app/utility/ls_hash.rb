class LsHash < ActiveSupport::HashWithIndifferentAccess
  def with_last_user(user_or_user_id)
    merge(last_user_id: extract_last_user_id_from(user_or_user_id))
  end

  private

  def extract_last_user_id_from(input)
    case input
    when String
      input.to_i
    when Integer
      input
    when User
      input.sf_guard_user_id
    when SfGuardUser
      input.id
    else
      raise ArgumentError, "Invalid class. Provided: #{input.class}"
    end
  end
end
