# frozen_string_literal: true

# rubocop:disable Security/Open

require 'uri'
require 'open-uri'
require_relative 'legislator_matcher/legislator'

# Processes congressional legistors yaml files and matches
# each legistor with existing LittleSis entities
class LegislatorMatcher
  CURRENT_YAML = 'https://theunitedstates.io/congress-legislators/legislators-current.yaml'
  HISTORICAL_YAML = 'https://theunitedstates.io/congress-legislators/legislators-historical.yaml'
  # CURRENT_YAML = Rails.root.join('tmp', 'legislators-current.yaml').to_s
  # HISTORICAL_YAML = Rails.root.join('tmp', 'legislators-historical.yaml').to_s

  HOUSE_OF_REPS = 12_884
  SENATE = 12_885

  CONGRESS_BOT_USER = 1
  CONGRESS_BOT_SF_USER = 1

  attr_reader :current_reps, :historical_reps, :reps

  def initialize
    open(CURRENT_YAML) { |f| @current_reps = YAML.load_file f }
    open(HISTORICAL_YAML) { |f| @historical_reps = YAML.load_file f }
    # Reps since 1990, returns array of YAML objects
    @reps = (historical_reps_after_1990 | @current_reps).map { |rep| Legislator.new(rep) }
  end

  def match_all
    @reps.each(&:match)
  end

  private

  def historical_reps_after_1990
    historical_reps.select do |r|
      r['terms'].select { |t| t['start'].slice(0, 4) >= '1990' }.present?
    end
  end
end

# rubocop:enable Security/Open
