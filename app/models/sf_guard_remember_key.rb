class SfGuardRememberKey < ApplicationRecord
  include SingularTable
  self.primary_key = "id"

  belongs_to :sf_guard_user, foreign_key: "user_id"
  has_one :user, through: :sf_guard_user


  def self.delete_keys_for_user(user)
    unless user.nil? || user.sf_guard_user_id.nil?
      destroy_all(user_id: user.sf_guard_user_id)
    end
  end

  # <User>, str -> str
  def self.create_new_key_for_user(user, ip)
    delete_keys_for_user(user)
    new_key = SecureRandom.hex
    create!(user_id: user.sf_guard_user_id, ip_address: ip, remember_key: new_key)
    new_key
  end

end
