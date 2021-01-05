# frozen_string_literal: true

class NyFilerEntity < ApplicationRecord
  belongs_to :ny_filer
  belongs_to :entity

  validates :ny_filer_id, presence: true
  validates :entity_id, presence: true
  validates :filer_id, presence: true

  after_create :rematch_existing_matches
  after_create :delete_from_unmatched_ny_filers
  before_destroy :add_to_unmatched_ny_filers

  ThinkingSphinx::Callbacks.append(self, :behaviours => [:sql])

  def rematch_existing_matches
    NyMatch.joins(:ny_filer_entity).where('ny_filer_entities.id = ?', id).find_each do |ny_match|
      ny_match.rematch
    end
  end

  def delete_from_unmatched_ny_filers
    UnmatchedNyFiler.find_by(ny_filer_id: ny_filer.id).destroy
  end

  def add_to_unmatched_ny_filers
    disclosure_count = NyDisclosure.where(filer_id: ny_filer.filer_id).count
    UnmatchedNyFiler.create(ny_filer_id: ny_filer.id, disclosure_count: disclosure_count)
  end

  handle_asynchronously :rematch_existing_matches
  handle_asynchronously :delete_from_unmatched_ny_filers
  handle_asynchronously :add_to_unmatched_ny_filers
end
