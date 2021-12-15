# frozen_string_literal: true

require_relative 'congress_importer/legislator'
require_relative 'congress_importer/legislator_matcher'
require_relative 'congress_importer/terms_importer'

# Processes congressional legistors yaml files and matches
# each legistor with existing LittleSis entities
#
# rake task                            method
#-----------------------------------------------------------------------------------------------
# legislators:import                   import_all                   Legislator#import!
# legislators:import_relationships     import_all_relationships     TermsImporter#import!
# legislators:import_party_memberships import_party_memberships     TermsImporter#import_party_memberships!
#
class CongressImporter
  DATA = {
    current: {
      url: 'https://theunitedstates.io/congress-legislators/legislators-current.yaml',
      path: Rails.root.join('data/congress').join('legislators-current.yaml').to_s
    },
    historical: {
      url: 'https://theunitedstates.io/congress-legislators/legislators-historical.yaml',
      path: Rails.root.join('data/congress').join('legislators-historical.yaml').to_s
    }
  }.freeze

  CONGRESS_BOT_USER = 10_040

  attr_reader :current_reps, :historical_reps, :reps

  def initialize(include_historical: false)
    self.class.download
    @current_reps = YAML.load_file DATA[:current][:path]

    if include_historical
      @historical_reps = YAML.load_file DATA[:historical][:path]
      # Reps since 1990, returns array of YAML objects
      @reps = (historical_reps_after_1990 | @current_reps).map { |rep| Legislator.new(rep) }
    else
      @reps = @current_reps.map { |rep| Legislator.new(rep) }
    end
  end

  def import_all
    @reps.each(&:import!)
  end

  def import_all_relationships
    @reps.each do |legislator|
      legislator.terms_importer.import!
    end
  end

  def import_party_memberships
    @reps.each do |legislator|
      legislator.terms_importer.import_party_memberships!
    end
  end

  def self.transaction(&block)
    PaperTrail.request(whodunnit: CONGRESS_BOT_USER.to_s) do
      ApplicationRecord.transaction(&block)
    end
  end

  def self.download
    FileUtils.mkdir_p Rails.root.join('data/congress')

    unless File.exist?(DATA.dig(:current, :path)) && File.stat(DATA.dig(:current, :path)).mtime > 2.days.ago
      Utility.stream_file url: DATA.dig(:current, :url), path: DATA.dig(:current, :path)
    end

    unless File.exist?(DATA.dig(:historical, :path)) && File.stat(DATA.dig(:historical, :path)).mtime > 2.days.ago
      Utility.stream_file url: DATA.dig(:historical, :url), path: DATA.dig(:historical, :path)
    end
  end

  private

  def historical_reps_after_1990
    historical_reps.select do |r|
      r['terms'].select { |t| t['start'].slice(0, 4) >= '1990' }.present?
    end
  end
end
