# frozen_string_literal: true

require 'congress_importer'

namespace :legislators do
  desc 'import legislators'
  task import: :environment do
    importer = CongressImporter.new
    importer.import_all
  end

  desc 'import legislator relationships'
  task import_relationships: :environment do
    importer = CongressImporter.new
    importer.import_all_relationships
  end

  desc 'import legislator party memberships'
  task import_party_memberships: :environment do
    importer = CongressImporter.new
    importer.import_party_memberships
  end
end
