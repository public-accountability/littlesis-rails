# frozen_string_literal: true

class NyFilerEntity < ApplicationRecord
  belongs_to :ny_filer
  belongs_to :entity

  validates :ny_filer_id, presence: true
  validates :entity_id, presence: true
  validates :filer_id, presence: true

  after_create :rematch_existing_matches

  def rematch_existing_matches
    NyMatch.joins(:ny_filer_entity).where('ny_filer_entities.id = ?', id).find_each do |ny_match|
      ny_match.rematch
    end
  end

  handle_asynchronously :rematch_existing_matches
end
