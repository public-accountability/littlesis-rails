# frozen_string_literal: true

class DashboardBulletin < ApplicationRecord
  DEFAULT_COLOR = 'rgba(0, 0, 0, 0.03)'
  default_scope { order(created_at: :desc) }

  validates :markdown, presence: true
  validates :color, css_color: true

  def display_color
    self[:color].presence || DEFAULT_COLOR
  end

  def self.last_bulletin_updated_at
    DashboardBulletin.reorder('updated_at desc').limit(1).pluck('updated_at').first
  end
end
