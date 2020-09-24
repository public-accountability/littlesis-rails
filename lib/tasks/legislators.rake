# frozen_string_literal: true

require 'importers'

namespace :legislators do
  desc 'import legislators'
  task import: :environment do
    begin
      ThinkingSphinx::Callbacks.suspend!
      importer = CongressImporter.new
      importer.import_all
    ensure
      ThinkingSphinx::Callbacks.resume!
    end
  end

  desc 'import legislator relationships'
  task import_relationships: :environment do
    begin
      ThinkingSphinx::Callbacks.suspend!
      importer = CongressImporter.new
      importer.import_all_relationships
    ensure
      ThinkingSphinx::Callbacks.resume!
    end
  end

  desc 'import legislator party memberships'
  task import_party_memberships: :environment do
    begin
      ThinkingSphinx::Callbacks.suspend!
      importer = CongressImporter.new
      importer.import_party_memberships
    ensure
      ThinkingSphinx::Callbacks.resume!
    end
  end

  desc 'Display statics about matches '
  task summary: :environment do
    importer = CongressImporter.new
    importer.match_all
    matches_by_type = importer
                        .reps
                        .map(&:match_type)
                        .each_with_object(Hash.new(0)) { |type, hash| hash[type] += 1 }

    with_matches = (matches_by_type[:id] + matches_by_type[:name])

    ColorPrinter.print_blue "There are #{importer.reps.length} legislators in the dataset"
    ColorPrinter.print_green "#{with_matches} have matches"
    ColorPrinter.print_magenta "#{matches_by_type[:id]} were matched by ID"
    ColorPrinter.print_magenta "#{matches_by_type[:name]} were matched by Name"
    ColorPrinter.print_red "#{matches_by_type[:none]} are missing matches"
  end

  desc 'Returns list of legislators from the YAML file who may not be in our database'
  task unmatched: :environment do
    importer = CongressImporter.new
    importer.match_all

    importer.reps.select { |l| l.match_type == :none }. each do |legislator|
      name = legislator['name'].slice('first', 'last').to_a.map(&:second).join(' ')
      bioguide = legislator['id']['bioguide']
      puts "#{name} (#{bioguide})"
    end
  end
end
