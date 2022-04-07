# frozen_string_literal: true

class PermissionPass < ApplicationRecord
  belongs_to :creator, class_name: 'User', inverse_of: :permission_passes
  validates :valid_to, :creator, presence: true
  validate :reasonable_validity_period
  validate :authorized_creator
  # Permission Passes can only be used for roles editor (4) and collaborator (5)
  validates :role, presence: true, numericality: { in: 4..5 }

  before_validation do
    self.token = SecureRandom.hex(20).encode('UTF-8') if token.blank?
    self.valid_from = Time.current if valid_from.blank?
  end

  def self.non_past
    where('valid_to > ?', Time.current)
  end

  def current?
    (valid_from..valid_to).cover? Time.current
  end

  def status
    if current?
      :current
    elsif valid_from > Time.current
      :upcoming
    elsif valid_to < Time.current
      :past
    end
  end

  # @param current_user [User]
  # @return [Boolean]
  def apply(current_user)
    if current_user.role.name == 'user'
      current_user.update(role: role)
    else
      %w[admin collaborator system].include?(current_user.role.name)
    end
  end

  private

  def reasonable_validity_period
    if valid_to < valid_from
      errors.add(:valid_to, 'must be after the valid from date')
    end

    if (valid_to - valid_from).round > 1.week.to_f
      errors.add(:base, 'The maximum validity period is 1 week')
    end
  end

  def authorized_creator
    errors.add(:creator, 'must be an admin') unless creator.admin?
  end
end
