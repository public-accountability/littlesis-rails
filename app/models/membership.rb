# frozen_string_literal: true

# If the membership is for a U.S. congressperson, elected_term contains
# a hash of information (state, district, etc.)
# See lib/congress_importer for the scraper.
class Membership < ApplicationRecord
  serialize :elected_term, type: Hash

  has_paper_trail on: [:update, :destroy], versions: { class_name: 'ApplicationVersion' }
  belongs_to :relationship, inverse_of: :membership

  def self.with_elected_term
    where('elected_term is not null')
  end
end
