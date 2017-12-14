class UserRequest < ActiveRecord::Base
  # fields: user_id, reviewer_id, type, status, source_id, dest_id
  belongs_to :user
  belongs_to :reviewer, class_name: 'User', foreign_key: 'reviewer_id'

  enum status: %i[pending approved denied]
  TYPES = { merge: 'MergeRequest' }

  validates_presence_of :user_id, :status, :type
  validates_inclusion_of :type, in: TYPES.values

  # abstract methods

  def approved_by!(_)
    raise NotImplementedError
  end

  def denied_by!(_)
    raise NotImplementedError
  end
end
