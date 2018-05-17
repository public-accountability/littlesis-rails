# frozen_string_literal: true

class CommonName < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  before_create :standardize_name

  private

  def standardize_name

    self.name = name.strip.upcase if name.present?
  end
end
