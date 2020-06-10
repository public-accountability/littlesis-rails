# frozen_string_literal: true

# Like ExternalEntity, this is a link between a Relationship
# and a row in ExternalData.
#
# The attribute `relationship_attributes` is a hash of attributes for the relationship
# that will be used when creating a new relationship
#
#    set_entity(entity1:, entity2)      matches entity2 or entity2
#      or use match_entity1_with & match_entity2_with
#    create_relationship
#
# TODO:
#  - validate category_id + entity primary ext
#  - add tag to relationship
#  - add reference while creating new relationship
#  - look for matching existing relationship
class ExternalRelationship < ApplicationRecord
  enum dataset: ExternalData::DATASETS
  belongs_to :external_data
  belongs_to :relationship, optional: true
  validates :category_id, presence: true

  serialize :relationship_attributes, Hash

  def matched?
    !relationship_id.nil?
  end

  def set_entity(entity1: nil, entity2: nil)
    # Prevent accidentally overwriting already matched entities
    if (entity1.present? && entity1_id.present?) || (entity2.present? && entity2_id.present?)
      raise EntityAlreadySetError
    end

    assign_attributes(entity1_id: Entity.entity_id_for(entity1)) if entity1.present?
    assign_attributes(entity2_id: Entity.entity_id_for(entity2)) if entity2.present?
    save
    self
  end

  def match_entity1_with(entity)
    set_entity entity1: entity
  end

  def match_entity2_with(entity)
    set_entity entity2: entity
  end

  def automatch
    raise NotImplementedError
  end

  # This creates a new relationship and connects this instance with it
  def create_new_relationship
    if matched?
      raise AlreadyMatchedError
    elsif entity1_id.nil? || entity2_id.nil?
      raise MissingMatchedEntityError
    end

    ApplicationRecord.transaction do
      relationship = Relationship.create!(
        attributes.slice('entity1_id', 'entity2_id', 'category_id').merge(relationship_attributes)
      )

      update!(relationship: relationship)
    end
  end

  class EntityAlreadySetError < Exceptions::LittleSisError; end
  class AlreadyMatchedError < Exceptions::MatchingError; end
  class MissingMatchedEntityError < Exceptions::LittleSisError; end
end
