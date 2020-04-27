# frozen_string_literal: true

class ExternalEntity < ApplicationRecord
  enum dataset: ExternalData::DATASETS

  serialize :match_data

  belongs_to :external_data, optional: false
  belongs_to :entity, optional: true

  def matched?
    !entity_id.nil?
  end
end
