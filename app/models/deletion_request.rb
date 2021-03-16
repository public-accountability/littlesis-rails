# frozen_string_literal: true

class DeletionRequest < UserRequest
  # fields: user_id, type, status, entity_id, justification

  validates :entity_id, presence: true
  belongs_to :entity, -> { unscope(where: :is_deleted) }

  def approve!
    entity.soft_delete
  end

  def self.cleanup
    find_each do |dr|
      if dr.entity.has_merges? || dr.entity.is_deleted
        Rails.logger.warn "denying redundant deletion request #{dr.id}"
        dr.denied_by!(User.system_user)
      end
    end
  end
end
