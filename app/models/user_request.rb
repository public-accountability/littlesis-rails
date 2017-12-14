class UserRequest < ActiveRecord::Base
  # fields: user_id, type, status, source_id, dest_id
  belongs_to :user

  enum status: %i[pending approved denied]
  TYPES = { merge: 'MergeRequest' }

  validates_presence_of :user_id, :status, :type
  validates_inclusion_of :type, in: TYPES.values

  def approve
    raise NotImplementedError
  end
end
