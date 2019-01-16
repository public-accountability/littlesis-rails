# frozen_string_literal: true

class CommonName < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  before_create :standardize_name

  def self.includes?(name)
    upcase_name = name.upcase
    Rails.cache.fetch("common_name/#{upcase_name}", expires_in: 30.days) do
      exists?(name: upcase_name)
    end
  end

  private

  def standardize_name
    self.name = name.strip.upcase if name.present?
  end
end
