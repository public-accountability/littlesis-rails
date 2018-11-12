# frozen_string_literal: true

# how to run: $ bin/rails runner ./lib/scripts/iapd.rb
# requires presence of "iapd.json" at root of repo
# generates two files: data/iapd_owners.csv and data/iapd_filers.csv

require 'json'
require Rails.root.join('lib', 'utility.rb').to_s

iapd_json_file = Rails.root.join('iapd.json')

iapd = JSON.parse(File.read(iapd_json_file))
          .select { |h| h["assets_under_management"] && h["assets_under_management"] >= 1_000_000_000 }

Filer = Struct.new(:name,
                   :sec_file_number,
                   :assets_under_management,
                   :matched_entity_name,
                   :matched_entity_id,
                   :matched_entity_url,
                   :automatch)

IapdRelationship = Struct.new(:filer_sec_number,
                              :schedule,
                              :ownership_code,
                              :status_acquired,
                              :owner_id,
                              :name,
                              :matched_entity_name,
                              :matched_entity_id,
                              :matched_entity_url,
                              :matched_entity_automatch,
                              :intermediary_name,
                              :intermediary_match_name,
                              :intermediary_match_id,
                              :intermediary_entity_url,
                              :intermediary_entity_automatch)

process_iapd = proc do |filer|
  f = Filer.new(*filer.values_at('name', 'sec_file_number', 'assets_under_management'))
  match_results = EntityMatcher.find_matches_for_org(f.name)
  unless match_results.empty?
    matched_entity        = match_results.first.entity
    f.matched_entity_name = matched_entity.name
    f.matched_entity_id   = matched_entity.id
    f.matched_entity_url  = matched_entity.url
    f.automatch           = match_results.automatchable?
  end
  f
end

process_owners = proc do |filer|
  filer['owners'].map do |owner|
    rel = IapdRelationship
            .new(filer['sec_file_number'], *owner.values_at('Schedule', 'Ownership Code', 'Status Acquired', 'OwnerID', 'Full Legal Name'))

    entity_matcher_method = owner['DE/FE/I'] == 'I' ? :find_matches_for_person : :find_matches_for_org
    owner_match_results = EntityMatcher.public_send(entity_matcher_method, rel.name)

    unless owner_match_results.empty?
      matched_entity               = owner_match_results.first.entity
      rel.matched_entity_name      = matched_entity.name
      rel.matched_entity_id        = matched_entity.id
      rel.matched_entity_url       = matched_entity.url
      rel.matched_entity_automatch = owner_match_results.automatchable?
    end

    if owner['Entity in Which']
      rel.intermediary_name = owner['Entity in Which']

      match_results = EntityMatcher.find_matches_for_org(owner['Entity in Which'])

      unless match_results.empty?
        matched_entity = match_results.first.entity
        rel.intermediary_match_name = matched_entity.name
        rel.intermediary_match_id = matched_entity.id
        rel.intermediary_entity_url = matched_entity.url
        rel.intermediary_entity_automatch = match_results.automatchable?
      end
    end
    rel
  end
end

Utility.save_hash_array_to_csv(
  Rails.root.join('data', 'iapd_filers.csv').to_s,
  iapd.map(&process_iapd).map(&:to_h)
)

Utility.save_hash_array_to_csv(
  Rails.root.join('data', 'iapd_owners.csv').to_s,
  iapd.map(&process_owners).flatten.map(&:to_h)
)
