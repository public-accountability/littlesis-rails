# frozen_string_literal: true

class UserPermission < ApplicationRecord
  belongs_to :user
  validates :user_id, presence: true
  validates :resource_type, presence: true

  def access_rules
    rules = super
    rules && ActiveSupport::HashWithIndifferentAccess.new(JSON.parse(rules))
  end

  def resource_type
    super&.constantize
  end
end
