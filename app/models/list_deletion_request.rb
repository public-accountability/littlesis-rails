# frozen_string_literal: true

class ListDeletionRequest < UserRequest
  # fields: user_id, type, status, list_id, justification

  validates :list_id, presence: true
  belongs_to :list, -> { unscope(:where) }

  def approve!
    list.soft_delete
  end
end
