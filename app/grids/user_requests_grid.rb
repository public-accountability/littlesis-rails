# frozen_string_literal: true

class UserRequestsGrid < BaseGrid
  scope do
    UserRequest.where(status: 'pending').order(created_at: :desc)
  end

  column(:type) do |request|
    case request.type
    when 'MergeRequest'
      'Merge'
    when 'DeletionRequest'
      'Delete Entity'
    when 'ListDeletionRequest'
      'Delete List'
    when 'ImageDeletionRequest'
      'Delete Image'
    end
  end

  column(:request, html: true) do |request|
    case request.type
    when 'MergeRequest'
      link_to request.source.name, merge_path(mode: 'review', request: request.id)
    when 'DeletionRequest'
      link_to (request.entity&.name || 'Entity'), review_deletion_requests_entity_path(request)
    when 'ListDeletionRequest'
      link_to (request.list&.name || 'List'), review_deletion_requests_list_path(request)
    when 'ImageDeletionRequest'
      link_to "Image #{request.image.id}", deletion_requests_image_url(request.id)
    end
  end

  column(:requester, html: true) do |request|
    link_to request.user.username, "/users/#{request.user.username}"
  end

  column(:justification)
end
