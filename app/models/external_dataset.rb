# frozen_string_literal: true

# This the base class for the Single Table Inheritance
# for external datasets. Subclasses need to be  named DatasetnameDatum
# Example: IapdDatum
class ExternalDataset < ApplicationRecord
  DATASETS = %i[iapd].freeze
  MODELS = DATASETS.map { |d| "#{d.to_s.capitalize}Datum" }.freeze

  belongs_to :entity, optional: true

  validates :type, presence: true, inclusion: { in: MODELS }
  validates :dataset_key, presence: true

  serialize :row_data, JSON
  serialize :match_data, JSON

  enum primary_ext: { person: 1, org: 2 }

  def name
    type.gsub('Datum', '').downcase
  end

  def matched?
    !entity_id.nil?
  end

  def matches(**kwargs)
    method = "find_matches_for_#{primary_ext}"
    EntityMatcher.public_send method, entity_name, **kwargs
  end

  def match_with(entity_or_entity_id)
    raise RowAlreadyMatched if matched?

    service.validate_match! entity: entity_or_entity_id, external_dataset: self
    assign_attributes entity_id: Entity.entity_id_for(entity_or_entity_id)
    service.match entity: entity_or_entity_id
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

  def row_data_class
    row_data['class'] if row_data
  end

  private

  def service
    @service ||= ExternalDatasetService.const_get(name.capitalize)
  end

  def entity_name
    case name
    when 'iapd'
      row_data.fetch('name')
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
