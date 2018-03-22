# frozen_string_literal: true

module Cmp
  class CmpPerson < CmpEntityImporter
    ATTRIBUTE_MAP = {
      fullname: [:entity, :name]
    }.freeze

    def cmp_relationships
      @cmp_relationships ||= Cmp::Datasets
                               .relationships
                               .select { |r| r['cmp_person_id'] == cmpid }
    end

    def related_cmp_org_ids
      cmp_relationships.map { |r| r['cmp_org_id'].to_i }
    end

    def associated_entity_ids
      return [] if related_cmp_org_ids.empty?
      CmpEntity
        .where(cmp_id: related_cmp_org_ids)
        .distinct
        .pluck('entity_id')
    end

    def matches
      EntityMatcher
        .find_matches_for_person(to_person_hash, associated: associated_entity_ids)
    end

    def to_person_hash
      {
        name_prefix: fetch("salutation"),
        name_first: fetch("firstname"),
        name_middle: fetch("middlename"),
        name_last: fetch("lastname"),
        name_suffix: fetch("suffix")
      }
    end
  end
end
