# frozen_string_literal: true

class UserRequest < ApplicationRecord
  # fields: user_id, reviewer_id, type, status, source_id, dest_id, justification
  belongs_to :user
  belongs_to :reviewer,
             class_name: 'User',
             foreign_key: 'reviewer_id',
             inverse_of: :reviewed_requests,
             optional: true

  enum status: %i[pending approved denied]
  TYPES = {
    merge: 'MergeRequest',
    deletion: 'DeletionRequest',
    image_deletion: 'ImageDeletionRequest',
    list_deletion: 'ListDeletionRequest'
  }.freeze

  validates :user_id, presence: true
  validates :status, presence: true
  validates :justification, presence: true
  validates :type, presence: true, inclusion: { in: TYPES.values }

  # abstract method(s)

  def approve!
    raise NotImplementedError
  end

  # concrete methods

  def description
    type.chomp("Request").downcase
  end

  def approved_by!(reviewer)
    approve!
    update!(status: :approved, reviewer: reviewer)
  end

  def denied_by!(reviewer)
    update!(status: :denied, reviewer: reviewer)
  end
end
