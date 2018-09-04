# frozen_string_literal: true

# A request to delete an image.
#
# source_id = image id
#
class ImageDeletionRequest < UserRequest
  validates :source_id, presence: true
  belongs_to :image, class_name: 'Image', foreign_key: 'source_id', inverse_of: :deletion_requests

  def approve!
    image.soft_delete
  end
end
