# frozen_string_literal: true

class UserPermission < ApplicationRecord
  serialize :access_rules, Hash

  belongs_to :user
  validates :user_id, presence: true
  validates :resource_type, presence: true

  def access_rules
    super&.with_indifferent_access
  end

  def resource_type
    rt = read_attribute(:resource_type)
    return rt.constantize if rt.present?
  end
end
