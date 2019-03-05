# frozen_string_literal: true

class ExternalDataset < ApplicationRecord
  DATASETS = %w[iapd].freeze
  validates :name, inclusion: { in: DATASETS }

  serialize :row_data, JSON
  serialize :match_data, JSON

  enum primary_ext: { person: 1, org: 2 }

  def matches
  end
end
