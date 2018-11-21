# frozen_string_literal: true

class SfGuardUserProfile < ApplicationRecord
  include SingularTable

  belongs_to :sf_guard_user, inverse_of: :sf_guard_user_profile, foreign_key: 'user_id'
end
