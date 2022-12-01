# frozen_string_literal: true

module DeleteUserService
  def self.run(user)
    @user = user
    ApplicationRecord.transaction do
      @user.network_maps.destroy_all
      @user.lists.destroy_all
      @user.user_profile&.destroy
      @user.update(
        role: :deleted,
        email: "#{user.id}@users.littlesis.org"
      )
    end
  end
end
