# frozen_string_literal: true

class RelationshipCategory < ApplicationRecord
  has_many :relationships, inverse_of: :category, dependent: :nullify

  def self.name_to_id
    @name_to_id ||= pluck(:name, :id)
      .to_h
      .transform_keys(&:downcase)
      .symbolize_keys
  end

  def self.id_to_name
    @id_to_name ||= name_to_id.invert
  end

  def self.valid_categories
    {
      person_to_person: without_entity_requirements(entity1: 'Org', entity2: 'Org').pluck(:id),
      person_to_org: without_entity_requirements(entity1: 'Org', entity2: 'Person').pluck(:id),
      org_to_person: without_entity_requirements(entity1: 'Person', entity2: 'Org').pluck(:id),
      org_to_org: without_entity_requirements(entity1: 'Person', entity2: 'Person').pluck(:id)
    }
  end

  def self.with_entity_requirements(entity1:, entity2:)
    where(entity1_requirements: entity1).or(where(entity2_requirements: entity2))
  end

  def self.without_entity_requirements(entity1:, entity2:)
    where.not(id: with_entity_requirements(entity1: entity1, entity2: entity2).pluck(:id))
  end
end
