# frozen_string_literal: true

namespace :legislators do
  desc 'Display statics about matches '
  task summary: :environment do
    matcher = LegislatorMatcher.new
    matcher.match_all
    matches_by_type = matcher
                        .reps
                        .map(&:match_type)
                        .each_with_object(Hash.new(0)) { |type, hash| hash[type] += 1 }

    with_matches = (matches_by_type[:id] + matches_by_type[:name])

    ColorPrinter.print_blue "There are #{matcher.reps.length} legislators in the dataset"
    ColorPrinter.print_green "#{with_matches} have matches"
    ColorPrinter.print_magenta "#{matches_by_type[:id]} were matched by ID"
    ColorPrinter.print_magenta "#{matches_by_type[:name]} were matched by Name"
    ColorPrinter.print_red "#{matches_by_type[:none]} are missing matches"
  end

  desc 'Returns list of legislators from the YAML file who may not be in our database'
  task unmatched: :environment do
    matcher = LegislatorMatcher.new
    matcher.match_all

    matcher.reps.select { |l| l.match_type == :none }. each do |legislator|
      name = legislator['name'].slice('first', 'last').to_a.map(&:second).join(' ')
      bioguide = legislator['id']['bioguide']
      puts "#{name} (#{bioguide})"
    end
  end

  # desc 'Returns list of legislators from the YAML file who may not be in our database, or whose entries are incomplete'
  # task unmatched: :environment do
  #   matcher = LegislatorMatcher.new
  #   matcher.find_unmatched
  # end

  # desc 'Prints count of legislators from the YAML file who may not be in our database, or whose entries are incomplete'
  # task unmatched_count: :environment do
  #   matcher = LegislatorMatcher.new
  #   puts matcher.find_unmatched.count
  # end

  # desc 'Matches legislators to Entity ids; returns array of tuples: [Entity id, YAML object]'
  # task match: :environment do
  #   matcher = LegislatorMatcher.new
  #   matcher.match
  # end

  # desc 'Searches for possible name matches to legislators with no id match'
  # task name_search_unmatched: :environment do
  #   matcher = LegislatorMatcher.new
  #   matcher.name_search_unmatched
  # end
end
