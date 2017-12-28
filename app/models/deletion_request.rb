class DeletionRequest < UserRequest
  # fields: user_id, type, status, entity_id

  validates_presence_of :entity_id
  belongs_to :entity

  def approve!
    entity.soft_delete
  end
end
