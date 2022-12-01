# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!, :block_restricted_user_access, except: [:success, :check_username]
  before_action :set_user, only: [:show, :edits, :role_request, :create_role_request]
  before_action :user_only, only: [:role_request, :create_role_request]
  before_action :user_or_admins_only, only: [:edits]

  # GET /users/:username
  def show
  end

  # GET /users/:username/edits
  def edits
    @edits = @user.recent_edits(params[:page]&.to_i || 1)
  end

  # GET /users/check_username
  def check_username
    render json: { username: params.require(:username),
                   valid: User.valid_username?(params.require(:username)) }
  end

  def success
  end

  # GET /users/:username/role_request
  def role_request
    @active_request = RoleUpgradeRequest.pending.find_by(user: current_user)
  end

  # POST /users/:username/role_request
  def create_role_request
    if %w[user editor].exclude?(current_user.role.name)
      raise Exceptions::LittleSisError, "#{current_user.username} has role #{current_user.role.name}. Refusing to create new RoleUpgradeRequest."
    end

    RoleUpgradeRequest.create!(role: current_user.role.name == 'editor' ? :collaborator : :editor,
                               user: current_user,
                               why: params.require(:why))

    redirect_to user_role_request_path(username: current_user.username)
  end

  private

  def set_user
    if params[:id].present? || params[:username]&.scan(/^[0-9]+$/).present?
      @user = User.find(params[:id] || params[:username])
    elsif params[:username].present?
      @user = User.find_by!(username: params[:username])
    else
      raise Exceptions::NotFoundError
    end
  end

  def user_only
    raise Exceptions::PermissionError unless current_user == @user
  end

  def user_or_admins_only
    raise Exceptions::PermissionError unless (current_user == @user) || current_user.admin?
  end

  def rate_limit

  end
end
