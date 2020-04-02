# frozen_string_literal: true

# rubocop:disable Security/Open

require 'uri'
require 'open-uri'
require_relative 'congress_importer/legislator'

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
  CURRENT_YAML = 'https://theunitedstates.io/congress-legislators/legislators-current.yaml'
  HISTORICAL_YAML = 'https://theunitedstates.io/congress-legislators/legislators-historical.yaml'
  # CURRENT_YAML = Rails.root.join('data', 'legislators-current.yaml').to_s
  # HISTORICAL_YAML = Rails.root.join('data', 'legislators-historical.yaml').to_s

  CONGRESS_BOT_USER = 10_040

  attr_reader :current_reps, :historical_reps, :reps

  def initialize
    open(CURRENT_YAML) { |f| @current_reps = YAML.load_file f }
    open(HISTORICAL_YAML) { |f| @historical_reps = YAML.load_file f }
    # Reps since 1990, returns array of YAML objects
    @reps = (historical_reps_after_1990 | @current_reps).map { |rep| Legislator.new(rep) }
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

  def self.transaction
    PaperTrail.request(whodunnit: CONGRESS_BOT_USER.to_s) do
      ApplicationRecord.transaction do
        yield
      end
    end
  end

  private

  def historical_reps_after_1990
    historical_reps.select do |r|
      r['terms'].select { |t| t['start'].slice(0, 4) >= '1990' }.present?
    end
  end
end

# rubocop:enable Security/Open
