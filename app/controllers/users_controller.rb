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

  # # GET /users/:id/edit_permissions
  # def edit_permissions
  # end

  # def add_permission
  #   @user.add_ability!(edit_permission_param)
  #   redirect_to edit_permissions_user_path(@user.id), notice: 'Permission was successfully added.'
  # end

  # def delete_permission
  #   @user.remove_ability!(edit_permission_param)
  #   redirect_to edit_permissions_user_path(@user.id), notice: 'Permission was successfully deleted.'
  # end


  # def restrict
  #   if @user.admin?
  #     redirect_to admin_users_path, notice: 'You can\'t restrict an admin user'
  #   elsif restrict_params == 'RESTRICT'
  #     @user.update(is_restricted: true)
  #     redirect_to admin_users_path, notice: "Successfully restricted #{@user.username}"
  #   elsif restrict_params == 'PERMIT'
  #     @user.update(is_restricted: false)
  #     redirect_to admin_users_path, notice: "Successfully removed restrictions from #{@user.username}"
  #   else
  #     redirect_to admin_users_path, notice: 'Incorrect paramters'
  #   end
  # end

  # def admin
  #   @users = User
  #              .includes(:user_profile)
  #              .where.not(role: :system)
  #              .where(User.matches_username_or_email(params[:q]))
  #              .order('created_at DESC')
  #              .page(params[:page] || 1)
  #              .per(50)
  # end

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

  # def restrict_params
  #   Rails.logger.warn params.inspect
  #   params[:status].try(:upcase)
  # end

  def user_or_admins_only
    raise Exceptions::PermissionError unless (current_user == @user) || current_user.admin?
  end
end
