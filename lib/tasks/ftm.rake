# frozen_string_literal: true

require Rails.root.join('lib', 'follow_the_money.rb').to_s
require Rails.root.join('lib', 'utility.rb').to_s

namespace :ftm do

  desc 'saves csv of matches'
  task save_matches: :environment do
    matches = FollowTheMoney.matches.map do |result|
      status = result.match_set.automatchable? ? '[X]' : '[ ]'
      puts "#{ColorPrinter.blue(status)}\t#{ColorPrinter.green(result.ftm_entity['CFS_Entity'])}"
      attributes = result.ftm_entity.to_h
      attributes['automatchable'] = result.match_set.automatchable?

      entity = result.match_set.first&.entity
      attributes['best_match'] = entity.present? ? "#{entity.name} (#{entity.id})" : ''
      attributes['best_match_url'] = entity.present? ? Routes.entity_url(entity) : ''
      attributes['best_match_values'] = result.match_set.first&.values&.to_a&.join('|')
      attributes
    end

    file_path = Rails.root.join('data', 'follow_the_money_matches.csv')
    Utility.save_hash_array_to_csv file_path, matches
  end
end
