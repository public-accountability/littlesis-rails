# frozen_string_literal: true

class ExternalRelationship < ApplicationRecord
  enum dataset: ExternalData::DATASETS
  belongs_to :external_data
  belongs_to :relationship, optional: true

  serialize :relationship_attributes, ActiveSupport::HashWithIndifferentAccess

  def matched?
    entity1_id.present? && entity2_id.present?
  end

  def match_with(entity1: nil, entity2: nil)
    if (entity1.present? && entity1_id.present?) || (entity2.present? && entity2_id.present?)
      raise AlreadyMatchedError
    end

    assign_attributes(entity1_id: Entity.entity_id_for(entity1)) if entity1.present?
    assign_attributes(entity2_id: Entity.entity_id_for(entity2)) if entity2.present?
    save
    self
  end

  class AlreadyMatchedError < Exceptions::MatchingError; end
end
