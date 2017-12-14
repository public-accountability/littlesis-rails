class UserRequest < ActiveRecord::Base
  # fields: user_id, reviewer_id, type, status, source_id, dest_id
  belongs_to :user
  belongs_to :reviewer, class_name: 'User', foreign_key: 'reviewer_id'

  enum status: %i[pending approved denied]
  TYPES = { merge: 'MergeRequest' }

  validates_presence_of :user_id, :status, :type
  validates_inclusion_of :type, in: TYPES.values

  # abstract method(s)

  def approve!
    raise NotImplementedError
  end

  # concrete methods

  def approved_by!(reviewer)
    approve!
    update!(status: :approved, reviewer: reviewer)
  end

  def denied_by!(reviewer)
    update!(status: :denied, reviewer: reviewer)
  end
end
