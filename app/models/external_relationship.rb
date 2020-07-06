# frozen_string_literal: true

# Like ExternalEntity, this is a link between a Relationship
# and a row in ExternalData.
#
# The attribute `relationship_attributes` is a hash of attributes for the relationship
# that will be used when creating a new relationship
#
#    set_entity(entity1:, entity2)      matches entity2 or entity2
#      or use match_entity1_with & match_entity2_with
#
# Many ExternalRelationships can be connected to the same Relationship
#
# TODO:
#  - validate category_id + entity primary ext
#  - handle relationship soft_delete
class ExternalRelationship < ApplicationRecord
  enum dataset: ExternalData::DATASETS

  belongs_to :external_data
  belongs_to :relationship, optional: true
  belongs_to :entity1, class_name: 'Entity', optional: true
  belongs_to :entity2, class_name: 'Entity', optional: true

  validates :category_id, presence: true

  after_initialize do
    extend "ExternalRelationship::Datasets::#{dataset.classify}".constantize
  end

  ##
  # Interface
  #
  def relationship_attributes
    raise NotImplementedError
  end

  def automatch
    raise NotImplementedError
  end

  def find_existing
    raise NotImplementedError
  end

  def potential_matches_entity1
    raise NotImplementedError
  end

  def potential_matches_entity2
    raise NotImplementedError
  end

  module Datasets
    module IapdScheduleA
      def relationship_attributes
        attrs = { position_attributes: {} }
        attrs[:start_date] = external_data.wrapper.min_acquired.to_s
        attrs[:description1] = external_data.wrapper.last_record['title_or_status']
        attrs[:is_current] = true if external_data.wrapper.last_record['iapd_year'] >= '2019'

        if Position.description_indicates_board_membership(attrs[:description1])
          attrs[:position_attributes][:is_board] = true
        end

        if Position.description_indicates_executive(attrs[:description1])
          attrs[:position_attributes][:is_executive] = true
        end

        attrs
      end

      def potential_matches_entity1(search_term = nil)
        name = search_term.presence || external_data.wrapper.last_record['name']

        if external_data.wrapper.last_record['owner_type'] == 'I' # person
          EntityMatcher.find_matches_for_person(name)
        else
          EntityMatcher.find_matches_for_org(name)
        end
      end

      def potential_matches_entity2(search_term = nil)
        if search_term.present?
          EntityMatcher.find_matches_for_org(search_term)
        else
          ExternalData
            .find_by(dataset_id: external_data.wrapper.advisor_crd_number)
            &.external_entity
            &.matches || []
        end
      end

      def automatch
        return if matched? || entity2_id.present?

        if external_data.wrapper.advisor_crd_number
          if (entity2 = ExternalLink.crd.find_by(link_id: external_data.wrapper.advisor_crd_number))
            update!(entity2_id: entity2.id)
          end
        end
      end

      # --> <Relationship> | nil
      def find_existing
        relationships = Relationship.where(attributes.slice('category_id', 'entity1_id', 'entity2_id')).to_a

        return nil if relationships.empty?

        if relationships.length > 1
          log "Found #{relationship.length} relationships. Selecting existing relationship #{relationships.first.id}"
        end

        relationships.first
      end
    end

    module NYSDisclosure
    end
  end

  def matched?
    !relationship_id.nil?
  end

  def entity1_matched?
    entity1_id.present?
  end

  def entity2_matched?
    entity2_id.present?
  end

  def set_entity(entity1: nil, entity2: nil)
    # Prevent accidentally overwriting already matched entities
    if (entity1.present? && entity1_id.present?) || (entity2.present? && entity2_id.present?)
      raise EntityAlreadySetError
    end

    assign_attributes(entity1_id: Entity.entity_id_for(entity1)) if entity1.present?
    assign_attributes(entity2_id: Entity.entity_id_for(entity2)) if entity2.present?
    match_action if entity1_matched? && entity2_matched?
    save!
    self
  end

  def match_entity1_with(entity)
    set_entity entity1: entity
  end

  def match_entity2_with(entity)
    set_entity entity2: entity
  end

  def match_from_params(entity_side:, params:)
    unless [1, 2].include?(entity_side) && (params.key?(:entity_id) || params.key?(:entity))
      raise Exceptions::LittleSisError
    end

    method = "match_entity#{entity_side}_with"

    ApplicationRecord.transaction do
      if params.key?(:entity_id)
        public_send(method, params.require(:entity_id).to_i)
      else
        entity = Entity.create!(params.require(:entity).permit(:name, :blurb, :primary_ext).to_h)
        public_send(method, entity)
      end
    end
    self
  end

  # If the ExternalRelationship is already matched, it will update the existing relationship
  # When a matching relationship can be found, it will use one that's already in our database,
  # otherwise a new relationship is created
  def match_action
    raise MissingMatchedEntityError unless entity1_id.present? || entity2_id.present?

    if matched?
      log "updating relationship #{relationship_id}"
      relationship.update!(relationship_attributes)
    elsif (existing_relationship = find_existing)
      log "updating relationship #{existing_relationship.id}"
      ApplicationRecord.transaction do
        update!(relationship: existing_relationship)
        relationship.update!(relationship_attributes)
      end
    else
      log 'creating a new relationship'
      create_relationship! relationship_attributes
                               .merge!(attributes.slice('entity1_id', 'entity2_id', 'category_id'))
    end
  end

  def presenter
    @presenter ||= ExternalRelationshipPresenter.new(self)
  end

  def self.unmatched
    where(relationship_id: nil)
  end

  def self.matched
    where.not(relationship_id: nil)
  end

  private

  def log(message)
    Rails.logger.info "[ExternalRelationship-#{id}] #{message}"
  end

  class EntityAlreadySetError < Exceptions::LittleSisError; end
  class AlreadyMatchedError < Exceptions::MatchingError; end
  class MissingMatchedEntityError < Exceptions::LittleSisError; end
  class IncompatibleRelationshipError < Exceptions::LittleSisError; end
end
