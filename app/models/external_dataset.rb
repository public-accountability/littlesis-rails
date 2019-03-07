# frozen_string_literal: true

class ExternalDataset < ApplicationRecord
  DATASETS = %w[iapd].freeze
  validates :name, inclusion: { in: DATASETS }

  serialize :row_data, JSON
  serialize :match_data, JSON

  enum primary_ext: { person: 1, org: 2 }

  def matched?
    !entity_id.nil?
  end

  def matches(**kwargs)
    method = "find_matches_for_#{primary_ext}"
    EntityMatcher.public_send method, entity_name, **kwargs
  end

  def match_with(entity_or_entity_id)
    raise RowAlreadyMatched if matched?
    service.validate_match!(entity_or_entity_id)
    assign_attributes entity_id: Entity.entity_id_for(entity_or_entity_id)
    service.match(entity_or_entity_id)
    save
    self
  end

  def unmatch
    raise NotYetMatched unless matched?
    service.unmatch
    assign_attributes entity_id: nil
    save
    self
  end

  private
  
  def service
    @service ||= ExternalDatasetService.const_get(name.capitalize).new(self)
  end

  def entity_name
    case name
    when 'iapd'
      row_data.fetch 'Full Legal Name'
    else
      raise Exceptions::LittleSisError, "Unknown dataset in ExternalDataset#entity_name: #{name}"
    end
  end

  # Exceptions #

  class RowAlreadyMatched < Exceptions::LittleSisError
    def message
      'ExternalDataset row already matched'
    end
  end

  class NotYetMatched < Exceptions::LittleSisError
    def message
      'Cannot unmatch. ExternalDataset row is not matched'
    end
  end
end
