# frozen_string_literal: true

require Rails.root.join('lib', 'follow_the_money.rb').to_s
require Rails.root.join('lib', 'query.rb').to_s

namespace :ftm do

  desc 'saves csv of matches'
  task save_matches: :environment do
    matches = FollowTheMoney.matches.map do |result|
      attributes = result.ftm_match.to_h
      attributes['automatchable'] = result.match_set.automatchable?
      attributes['best_match'] = "#{result.match_set.first&.entity&.name} (#{result.match_set.first&.entity&.id})"
      attributes['best_match_values'] = result.match_set.first&.values&.to_a&.join('|')
      attributes
    end

    file_path = Rails.root.join('data', 'follow_the_money_matches.csv')
    Query.save_hash_array_to_csv file_path, matches
  end
end
