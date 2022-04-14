# frozen_string_literal: true

class UserProfile < ApplicationRecord
  belongs_to :user, inverse_of: :user_profile

  # validates :reason, signup_reason: true

  def full_name
    "#{name_first} #{name_last}".strip
  end
end
