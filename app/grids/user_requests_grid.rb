# frozen_string_literal: true

class UserRequestsGrid < BaseGrid
  scope do
    UserRequest.where(status: 'pending').where("type != 'UserFlag'").order(created_at: :desc)
  end

  column(:type, order: false) do |request|
    {
      'MergeRequest' => 'Merge',
      'DeletionRequest' => 'Delete Entity',
      'ListDeletionRequest' => 'Delete List',
      'ImageDeletionRequest' => 'Delete Image',
      'UserFlag' => 'Flag'
    }.fetch(request.type)
  end

  column(:created_at, header: "When") do |request|
    request.created_at.strftime('%m/%d/%Y %T')
  end

  column(:request, html: true) do |request|
    case request.type
    when 'MergeRequest'
      link_to request.source.name, merge_path(mode: 'review', request: request.id)
    when 'DeletionRequest'
      link_to(request.entity&.name || 'Entity', review_deletion_requests_entity_path(request))
    when 'ListDeletionRequest'
      link_to(request.list&.name || 'List', review_deletion_requests_list_path(request))
    when 'ImageDeletionRequest'
      link_to "Image #{request.image&.id}", review_deletion_requests_image_path(request)
    when 'UserFlag'
      link_to 'Flag', request.page
    end
  end

  column(:requester, html: true) do |request|
    if request.user
      link_to request.user.username, "/users/#{request.user.username}"
    else
      mail_to request.email
    end
  end

  column(:justification, order: false)
end
