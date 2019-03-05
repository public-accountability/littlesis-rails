# frozen_string_literal: true

class ExternalDataset < ApplicationRecord
  DATASETS = %w[iapd].freeze
  validates :name, inclusion: { in: DATASETS }

  serialize :row_data, JSON
  serialize :match_data, JSON

  enum primary_ext: { person: 1, org: 2 }

  def matches(**kwargs)
    method = "find_matches_for_#{primary_ext}"
    EntityMatcher.public_send method, entity_name, **kwargs
  end

  private

  def entity_name
    case name
    when 'iapd'
      row_data.fetch 'Full Legal Name'
    else
      raise Exceptions::LittleSisError, "Unknown dataset in ExternalDataset#entity_name: #{name}"
    end
  end
end
