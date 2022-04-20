# frozen_string_literal: true

class UserRoleUpgradeRequestsGrid < BaseGrid
  scope do
    RoleUpgradeRequest.where(status: 'pending').order(created_at: :desc)
  end

  column(:user, html: true) do |request|
    link_to request.user.username, "/users/#{request.user.username}"
  end

  column(:created_at, header: "When", order: true) do |request|
    request.created_at.strftime('%m/%d/%Y')
  end

  column(:status, order: false, html: true) do |request|
    if request.pending?
      path = admin_role_upgrade_request_path(request)

      tag.div(class: 'ps-2 pe-2') do
        button_to("Approve", path, params: { status: 'approve' }, form_class: 'd-inline-block', class: 'btn btn-sm btn-success', method: :patch) +
          button_to("Deny", path, params: { status: 'deny' }, form_class: 'd-inline-block ms-1', class: 'btn btn-sm btn-danger', method: :patch)
      end

    else
      request.status
    end
  end
  column(:why, order: false)
end
