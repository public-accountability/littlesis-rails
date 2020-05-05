# frozen_string_literal: true

class ExternalRelationship < ApplicationRecord
  enum dataset: ExternalData::DATASETS
  belongs_to :external_data
  belongs_to :relationship, optional: true

  serialize :relationship_attributes, ActiveSupport::HashWithIndifferentAccess
end
