# frozen_string_literal: true

class DeletionRequest < UserRequest
  # fields: user_id, type, status, entity_id, justification

  validates :entity_id, presence: true
  belongs_to :entity

  def approve!
    entity.soft_delete
  end
end
