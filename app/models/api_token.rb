class ApiToken < ActiveRecord::Base
  belongs_to :user
  validates :user_id, presence: true, uniqueness: true

  before_create :set_token

  def reset!
    set_token
    save!
  end

  def self.valid_token?(token)
    find_by_token(token).present?
  end

  private

  def set_token
    self.token = SecureRandom.urlsafe_base64
  end
end
