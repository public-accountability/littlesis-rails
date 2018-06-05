# frozen_string_literal: true

class ExternalLink < ApplicationRecord
  validates :link_type, presence: true
  validates :entity_id, presence: true
  validates :link_id, presence: true

  belongs_to :entity
end
