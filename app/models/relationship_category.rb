# frozen_string_literal: true

class RelationshipCategory < ApplicationRecord
  has_many :relationships, inverse_of: :category

  def self.valid_categories
    return @valid_categories if defined?(@valid_categories)

    person_to_person = (1..12).to_a
    person_to_org = (1..12).to_a
    org_to_person = (1..12).to_a
    org_to_org = (1..12).to_a
    all.each do |cat|
      if cat.entity1_requirements == 'Person'
        org_to_person.delete(cat.id)
        org_to_org.delete(cat.id)
      end

      if cat.entity1_requirements == 'Org'
        person_to_org.delete(cat.id)
        person_to_person.delete(cat.id)
      end

      if cat.entity2_requirements == 'Person'
        org_to_org.delete(cat.id)
        person_to_org.delete(cat.id)
      end

      if cat.entity2_requirements == 'Org'
        org_to_person.delete(cat.id)
        person_to_person.delete(cat.id)
      end
    end

    @valid_categories = {
      person_to_person: person_to_person,
      person_to_org: person_to_org,
      org_to_person: org_to_person,
      org_to_org: org_to_org
    }
  end

  def self.lookup
    @lookup ||= all.map do |rc|
      [rc.id, rc.attributes.except('created_at', 'updated_at').with_indifferent_access]
    end.to_h
  end

  # @param entity1 [Entity]
  # @param entity2 [Entity]
  # @return [Array<Integer>]
  def self.for(entity1, entity2)
    valid_categories.fetch (entity1.primary_ext.downcase + "_to_" + entity2.primary_ext.downcase).to_sym
  end
end
