# frozen_string_literal: true

class ExternalEntity < ApplicationRecord
  enum dataset: ExternalData::DATASETS

  serialize :match_data

  belongs_to :external_data, optional: false
  belongs_to :entity, optional: true

  def matched?
    !entity_id.nil?
  end

  def matches
    case dataset
    when 'iapd_advisors'
      org_name = external_data.data.last['name']
      EntityMatcher.find_matches_for_org(org_name)
    else
      raise NotImplementedError
    end
  end
end
