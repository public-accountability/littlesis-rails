class NyFilerEntity < ActiveRecord::Base
  belongs_to :ny_filer
  belongs_to :entity

  validates_presence_of :ny_filer_id, :entity_id, :filer_id

  after_create :rematch_existing_matches

  def rematch_existing_matches
    NyMatch.joins(:ny_filer_entity).where('ny_filer_entities.id = ?', id).find_each do |ny_match|
      ny_match.rematch
    end
  end

  handle_asynchronously :rematch_existing_matches
end
