# frozen_string_literal: true

class AdminController < ApplicationController
  before_action :authenticate_user!, :admins_only

  def home
    @requests = UserRequestsGrid.new(params[:user_requests_grid]) do |scope|
      scope.page(params[:requests_page] || 1).per(10)
    end

    @role_upgrade_requests = UserRoleUpgradeRequestsGrid.new(params[:user_role_request_grid]) do |scope|
      scope.page(params[:role_upgrade_page] || 1).per(10)
    end

    @users = UserSignupsGrid.new do |scope|
      scope.page(params[:user_signups_page] || 1).per(10)
    end
  end

  def tags
  end

  def maps
  end

  def stats
    @page = params.fetch('page', 1)
    @time = params.fetch('time', 'week')
  end

  def test
  end

  def test_email
    NotificationMailer.test_email(content: params[:content], to: params[:to]).deliver_later
    redirect_to '/admin', notice: 'Test email sent'
  end

  def users
    params[:page] ||= 1

    @users = User
               .includes(:user_profile)
               .where.not(role: :system)
               .where(User.matches_username_or_email(params[:q]))
               .order('created_at DESC')
               .page(params[:page])
               .per(25)
  end

  # /admin/users/:userid/set_role { role: [role_name] }
  def set_role
    user = User.find(params.require(:userid))
    user.update!(role: params.require(:role))
    render json: { status: 'ok', role: user.role.name }
  end

  # POST /admin/users/:userid/resend_confirmation_email
  def resend_confirmation_email
    User.find(params.require(:userid)).resend_confirmation_instructions
    render json: { status: 'ok' }
  end

  # POST /admin/users/:userid/reset_password
  def reset_password
    user = User.find(params.require(:userid))

    # resets the user password
    # password = SecureRandom.hex(22)
    # user.reset_password(password, password)

    # emails instructions to user's email
    user.send_reset_password_instructions
    render json: { status: 'ok' }
  end

  # POST /admin/users/:userid/delete_user
  def delete_user
    user = User.find(params.require(:userid))
    job = DeleteUserJob.scheduled_job(user.id).first
    if job.present?
      render json: { status: 'ok', message: "scheduled at #{job['scheduled_at']}" }
    else
      wait_time = 12.hours
      job = DeleteUserJob.set(wait: wait_time).perform_later(user.id)
      render json: { status: 'ok', message: "scheduled at #{wait_time.from_now}" }
    end
  end

  # PATCH /admin/role_upgrade_requests/:id
  def update_role_upgrade_request
    request = RoleUpgradeRequest.find(params[:id])
    case params.require(:status)
    when 'approve'
      request.approve!
    when 'deny'
      request.deny!
    else
      return head(:internal_server_error)
    end
    flash[:notice] = "#{request.status} role upgrade request for #{request.user.username}."
    redirect_to '/admin'
  end

  def entity_matcher
  end

  def object_space_dump
    FileUtils.mkdir_p  Rails.root.join("tmp/object_space")
    filepath = Rails.root.join("tmp/object_space/#{Process.pid}.#{DateTime.current.to_i}.dump").to_s
    require 'objspace'
    ObjectSpace.trace_object_allocations_start
    GC.start
    ObjectSpace.dump_all(output: File.open(filepath, "w"))
    render plain: "saved #{filepath}"
  end
end
