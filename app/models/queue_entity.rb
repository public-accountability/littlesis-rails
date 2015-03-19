class QueueEntity < ActiveRecord::Base
  belongs_to :entity, inverse_of: :queue_entities

  scope :skipped, -> { where(is_skipped: true) }

  def self.skip_entity(queue, entity_id, user_id = nil)
    find_or_create_by(queue: queue, entity_id: entity_id, user_id: user_id) do |qe|
      qe.is_skipped = true
    end
  end

  def self.skipped_entity_ids(queue)
    where(queue: queue, is_skipped: true).pluck(:entity_id).uniq
  end

  def self.filter_skipped(queue, entity_ids)
    return [] unless entity_ids.present?
    entity_ids - skipped_entity_ids(queue)
  end
end