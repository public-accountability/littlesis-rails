# frozen_string_literal: true

class ExternalRelationship < ApplicationRecord
  enum dataset: ExternalData::DATASETS
  belongs_to :external_data
  belongs_to :relationship, optional: true

  serialize :relationship_attributes, ActiveSupport::HashWithIndifferentAccess

  def matched?
    entity1_id.present? && entity2_id.present?
  end
end
