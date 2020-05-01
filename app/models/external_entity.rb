# frozen_string_literal: true

class ExternalEntity < ApplicationRecord
  enum dataset: ExternalData::DATASETS
  enum priority: { default: 0 }

  serialize :match_data

  belongs_to :external_data, optional: false
  belongs_to :entity, optional: true

  def match_with(entity_or_id)
    if update(entity_id: Entity.entity_id_for(entity_or_id))
      match_action
    else
      raise Exceptions::ExternalEntityMatchingError
    end
  end

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

  def match_action
    case dataset
    when 'iapd_advisors' # Create CRD external link
      crd_number = external_data.dataset_id
      ExternalLink.crd.create!(entity_id: entity_id, link_id: crd_number)
    else
      raise NotImplementedError
    end
  end
end
