# frozen_string_literal: true

# This the base class for the Single Table Inheritance
# for external datasets. Subclasses need to be  named DatasetnameDatum
# Example: IapdDatum
class ExternalDataset < ApplicationRecord
  DATASETS = %i[iapd].freeze
  MODELS = DATASETS.map { |d| "#{d.to_s.capitalize}Datum" }.freeze

  # FLOWS = {
  #   iapd: %w[advisors owners search]
  # }.with_indifferent_access.freeze

  belongs_to :entity, optional: true

  validates :type, presence: true, inclusion: { in: MODELS }
  validates :dataset_key, presence: true

  serialize :row_data, JSON
  serialize :match_data, JSON

  enum primary_ext: { person: 1, org: 2 }

  def name
    type.gsub('Datum', '').downcase
  end

  def unmatched?
    entity_id.nil?
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

    entity = Entity.entity_for(entity_or_entity_id)

    ExternalDatasetService.validate_match! external_dataset: self, entity: entity
    assign_attributes entity_id: entity.id
    ExternalDatasetService.match external_dataset: self, entity: entity
    unless save
      Rails.logger.warn('ExternalDataset') { "Failed to match ExternalDataset #{id} with Entity #{entity.id}" }
      assign_attributes entity_id: nil
    end
    self
  end

  def unmatch
    raise NotYetMatched unless matched?

    ExternalDatasetService.unmatch external_dataset: self
    assign_attributes entity_id: nil
    save
    self
  end

  def row_data_class
    row_data['class'] if row_data
  end

  def self.unmatched
    where(entity_id: nil)
  end

  def self.matched
    where.not(entity_id: nil)
  end

  private

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
