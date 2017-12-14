class MergeRequest < UserRequest
  # fields: user_id, type, status, source_id, dest_id

  validates_presence_of %i[source_id dest_id]

  belongs_to :source, class_name: 'Entity', foreign_key: 'source_id'
  belongs_to :dest, class_name: 'Entity', foreign_key: 'dest_id'

  def approved_by!(reviewer)
    source.merge_with(dest)
    update!(status: :approved, reviewer: reviewer)
  end

  def denied_by!(reviewer)
    update!(status: :denied, reviewer: reviewer)
  end
end
