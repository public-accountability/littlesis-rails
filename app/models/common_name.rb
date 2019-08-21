# frozen_string_literal: true

class CommonName < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  before_create :standardize_name

  CACHE_EXPIRY = 30.days

  def self.includes?(name)
    upcase_name = name.upcase
    Rails.cache.fetch(cache_key(upcase_name), expires_in: CACHE_EXPIRY) do
      exists?(name: upcase_name)
    end
  end

  def self.warm_cache
    all.pluck(:name).each { |name| includes?(name) }
  end

  private_class_method def self.cache_key(value)
    "common_name/#{value}"
  end

  private

  def standardize_name
    self.name = name.strip.upcase if name.present?
  end
end
