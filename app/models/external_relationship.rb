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
#  - handle entity soft_delete
class ExternalRelationship < ApplicationRecord
  include Datasets::Interface
  enum dataset: ExternalData::DATASETS

  belongs_to :external_data
  belongs_to :relationship, optional: true
  belongs_to :entity1, class_name: 'Entity', optional: true
  belongs_to :entity2, class_name: 'Entity', optional: true

  validates :category_id, presence: true

  after_initialize do
    extend "ExternalRelationship::Datasets::#{dataset.classify}".constantize
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
  # When a matching relationship can be found, it will use one that's already in our database, otherwise a new relationship is created
  def match_action
    raise MissingMatchedEntityError unless entity1_id.present? || entity2_id.present?

    if !matched? && (existing_relationship = find_existing)
      update!(relationship: existing_relationship)
    end

    if matched?
      relationship.update!(relationship_attributes)
    else
      create_relationship!(attributes.slice('entity1_id', 'entity2_id', 'category_id'))
      if dataset == 'fec_contribution'
        relationship.update!(relationship_attributes(is_new: true))
      else
        relationship.update!(relationship_attributes)
      end
    end

    after_match_action
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
