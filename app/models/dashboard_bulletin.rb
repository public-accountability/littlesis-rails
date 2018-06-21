# frozen_string_literal: true

class DashboardBulletin < ApplicationRecord
  default_scope { order(created_at: :desc) }

  def self.last_bulletin_updated_at
    DashboardBulletin.reorder('updated_at desc').limit(1).pluck('updated_at').first
  end
end
