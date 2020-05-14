# frozen_string_literal: true

# External Entity links a LittleSis Entity to a row in External Data
#
#   ExternalEntity#matches              ResultSet of potential matches
#   ExternalEntity#automatch            Automatically matches, if possible
#   ExternalEntity#match_with(<Entity>) Markes
class ExternalEntity < ApplicationRecord
  enum dataset: ExternalData::DATASETS
  enum priority: { default: 0 }

  serialize :match_data

  belongs_to :external_data, optional: false
  belongs_to :entity, optional: true

  before_create :set_primary_ext

  # is it already connected to an entity
  def matched?
    !entity_id.nil?
  end

  # Uses EntityMatcher to look for potential matches.
  # return EntityMatcher::EvaluationResultSet
  def matches
    case dataset
    when 'iapd_advisors'
      # TODO handle additional aliases
      org_name = external_data.data['names'].first
      EntityMatcher.find_matches_for_org(org_name)
    else
      raise NotImplementedError
    end
  end

  # If the dataset type can be automated, #automatch
  # will look for a littlesis entity and call #match_with
  # if a matching entity if found.
  # Otherwise, it's a noop.
  def automatch
    return self if matched?

    case dataset
    when 'iapd_advisors'
      if ExternalLink.crd_number?(external_data.dataset_id)
        if (external_link = ExternalLink.crd.find_by(link_id: external_data.dataset_id))
          match_with(external_link.entity)
        end
      end
    end
    self
  end

  # Performs a match between the external data and an entity.
  # If already matched, an error is raised.
  # There are dataset-specific side effects of matching. see #match_action
  def match_with(entity_or_id)
    raise AlreadyMatchedError, "ExternalEntity (#{id}) is already matched" if matched?

    ApplicationRecord.transaction do
      update!(entity_id: Entity.entity_id_for(entity_or_id))
      match_action
    end
    self
  end

  class AlreadyMatchedError < Exceptions::MatchingError; end

  private

  # Performs entity data addition tasks -- i.e. creating and ExternalLink
  # for the newly matched entity.
  def match_action
    case dataset
    when 'iapd_advisors'
      entity.add_tag('iapd')

      if ExternalLink.crd_number?(external_data.dataset_id)
        ExternalLink.crd.find_or_create_by!(entity_id: entity_id,
                                            link_id: external_data.dataset_id)
      end
    else
      raise NotImplementedError
    end
  end

  def set_primary_ext
    case dataset
    when 'iapd_advisors'
      self.primary_ext = 'Org'
    end
  end
end
