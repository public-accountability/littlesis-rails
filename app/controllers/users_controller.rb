# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!, :block_restricted_user_access, except: [:success, :check_username]
  before_action :set_user, only: [:show, :edits]
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

  def user_or_admins_only
    raise Exceptions::PermissionError unless (current_user == @user) || current_user.admin?
  end
end
