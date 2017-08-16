module ListHelpers
  def sign_in_and_get(user, action)
    sign_in user if user.present?
    get action, id: '123'
  end
end
