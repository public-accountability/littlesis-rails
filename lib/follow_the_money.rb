# frozen_string_literal: true

require 'csv'

module FollowTheMoney
  def self.entities
    @entities ||= read_csv('LittleSis1000Entities.csv')
  end

  def self.relationships
    @relationships ||= read_csv 'LittleSis1000EntitiesRelationships.csv'
  end

  def self.related_entity_names_for(id)
    relationships
      .select { |row| row['CFS_EID'] == id }
      .map { |row| row['RelatedEntity'] }
  end

  def self.related_orgs(org_names)
    org_names.map do |name|
      EntityMatcher
        .find_matches_for_org(name)
        .automatch&.entity&.id
    end.compact
  end

  def self.related_orgs_for(id)
    related_orgs related_entity_names_for(id)
  end

  MatchResult = Struct.new(:ftm_entity, :match_set)

  def self.matches
    entities.map do |entity|
      match_set = EntityMatcher
                    .find_matches_for_person(entity['CFS_Entity'], associated: related_orgs_for(entity['CFS_EID']))

      Rails.logger.debug "Match: #{match_set.first&.entity&.name} (#{match_set.first&.entity&.id})"
      Rails.logger.debug "Match Values: #{match_set.first&.values&.to_a&.join('|')}"

      MatchResult.new(entity, match_set)
    end
  end

  def self.read_csv(file_name)
    CSV.read Rails.root.join('data', file_name), headers: true
  end

  private_class_method :read_csv
end
