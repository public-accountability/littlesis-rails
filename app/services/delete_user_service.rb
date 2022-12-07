# frozen_string_literal: true

module DeleteUserService
  def self.run(user)
    ApplicationRecord.transaction do
      user.network_maps.each(&:soft_delete)
      user.lists.each(&:soft_delete)
      user.user_profile&.destroy
      user.update!(
        role: :deleted,
        email: "#{user.id}@users.littlesis.org"
      )
    end
  end
end
