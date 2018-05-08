# frozen_string_literal: true

class UserPermission < ApplicationRecord
  serialize :access_rules, Hash

  belongs_to :user
  validates :user_id, presence: true
  validates :resource_type, presence: true

  def access_rules
    rules = super
    ActiveSupport::HashWithIndifferentAccess.new(rules) if rules
  end

  def resource_type
    super&.constantize
  end
end
