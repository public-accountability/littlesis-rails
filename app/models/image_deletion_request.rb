# frozen_string_literal: true

# A request to delete an image.
#
# source_id = image id
#
class ImageDeletionRequest < UserRequest
  validates :source_id, presence: true
  belongs_to :image, class_name: 'Image', foreign_key: 'source_id', inverse_of: :deletion_requests
  belongs_to :entity, optional: true

  # after_create :send_notification_email

  def approve!
    image.soft_delete
  end

  private

  def send_notification_email
    NotificationMailer.image_deletion_request_email(self).deliver_later
  end
end
