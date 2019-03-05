# frozen_string_literal: true

class ExternalDataset < ApplicationRecord
  DATASETS = %w[iapd].freeze
  validates :name, inclusion: { in: DATASETS }

  serialize :row_data, JSON
  serialize :match_data, JSON

  def matches
    
  end
end
