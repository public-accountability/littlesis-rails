# frozen_string_literal: true

require_relative './utility.rb'

module IapdImporter
  IAPD_JSON_FILE = Rails.root.join('top_200.json').to_s

  Advisor = Struct.new(:data, :business) do
    delegate :entity, to: :business
    delegate :fetch, to: :data

    def sec_url
      "https://adviserinfo.sec.gov/Firm/#{data['crd_number']}"
    end

    def associated_entity_ids
      return @_associated_entity_ids if defined?(@_associated_entity_ids)

      @_associated_entity_ids = entity.hierarchy_relationships.pluck(:entity1_id, :entity2_id).flatten.uniq
    end

    def direct_owner_matches
      direct_owners.map do |direct_owners|
        direct_owners.tap do |owner|
          match_results = IapdImporter.matches_for_owner(name: owner['Full Legal Name'],
                                                         primary_ext: owner['DE/FE/I'],
                                                         associated: associated_entity_ids)
          owner['advisor_name'] = fetch('name')
          owner['advisor_entity_id'] = entity.id
          owner['advisor_crd_number'] = fetch('crd_number')
          owner['match_id'] = match_results.first&.entity&.id
          owner['match_url'] = match_results.first&.entity&.url
          owner['match_name'] = match_results.first&.entity&.name
          owner['automatchable'] = match_results.automatchable?
          owner['match_values'] = match_results.first&.values&.to_a&.join('|')
        end
      end
    end

    def direct_owners
      fetch('owners').select { |o| o['Schedule'] == 'A' }
    end

    alias schedule_a direct_owners

    def indirect_owners
      fetch('owners').select { |o| o['Schedule'] == 'B' }
    end

    alias schedule_b indirect_owners
  end

  def self.direct_owners_csv
    Utility.save_hash_array_to_csv(
      Rails.root.join('data', "direct_owners_#{Time.current.strftime('%F')}.csv"),
      advisors.map(&:direct_owner_matches).flatten
    )
  end

  # --> [Advisor]
  def self.advisors
    Business.includes(:entity).with_crd_number.find_each.map do |business|
      Advisor.new find_by_crd_number(business.crd_number), business
    end
  end

  def self.dataset
    return @_dataset if defined?(@_dataset)

    @_dataset = JSON.parse(File.read(IAPD_JSON_FILE))
  end

  # Str|Int --> Hash
  def self.find_by_crd_number(crd_number)
    dataset.find { |h| h['crd_number'] == crd_number.to_i }
  end

  def self.owner_matches(owners, associated_entity_ids)
    owners.map do |owner|
      matches_for_owner name: owner['Full Legal Name'],
                        primary_ext: owner['DE/FE/I'] == 'I' ? :person : :org,
                        associated: associated_entity_ids
    end
  end

  def self.matches_for_owner(name:, primary_ext:, associated:)
    unless %w[org person DE FE I].include?(primary_ext.to_s)
      raise ArgumentError, "invalid primary_ext: #{primary_ext}"
    end

    if %w[DE FE I].include?(primary_ext)
      primary_ext = primary_ext == 'I' ? 'person' : 'org'
    end

    EntityMatcher.public_send "find_matches_for_#{primary_ext}",
                               name,
                               associated: associated
  end
end
