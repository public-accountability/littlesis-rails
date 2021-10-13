# frozen_string_literal: true

# Featured links associated with an entity displayed on the profile page sidebar
class FeaturedResource < ApplicationRecord
  belongs_to :entity
  validates :title, presence: true, length: { maximum: 300 }
  validates :url, presence: true, url: true
end
