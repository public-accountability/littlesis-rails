# frozen_string_literal: true

class PermissionPass < ApplicationRecord
  belongs_to :creator, class_name: 'User', inverse_of: :permission_passes

  PERMITTED_ABILITIES = (UserAbilities::ALL_ABILITIES.to_a - [:admin]).freeze

  serialize :abilities, UserAbilities

  validates :valid_to, :creator, :abilities, presence: true
  validate :reasonable_validity_period
  validate :authorized_creator
  validate :permitted_abilities

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

  def permitted_abilities
    (abilities.to_a - PERMITTED_ABILITIES).each do |illegal_ability|
      errors.add(:abilities, "cannot include #{illegal_ability}")
    end
  end
end
