# frozen_string_literal: true

# Request to become an Editor or Collaborator
# Columns: user_id, role, status, why, created_at, updated_at
class RoleUpgradeRequest < ApplicationRecord
  enum :role, User::ROLES.slice(:editor, :collaborator), default: :editor
  enum :status, { pending: 0, approved: 1, denied: 2 }, default: :pending
  belongs_to :user

  validates :why, length: { minimum: 30 }

  def approve!
    ApplicationRecord.transaction do
      user.update! role: role
      update! status: :approved
    end
  end

  def deny!
    update! status: :denied
  end
end
