class UserPermission < ApplicationRecord
  belongs_to :user
  validates_presence_of :user_id, :resource_type

  def access_rules
    rules = super
    rules && HashWithIndifferentAccess.new(JSON.parse(rules))
  end

  def resource_type
    super&.constantize
  end
end
