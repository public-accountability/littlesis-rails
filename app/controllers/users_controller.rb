class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit_permissions, :add_permission, :delete_permission]
  before_action :authenticate_user!
  before_filter :admins_only, except: [:show]
  
  # get /users
  def index
    @users = User
      .includes(:groups)
      .joins("INNER JOIN sf_guard_user ON sf_guard_user.id = users.sf_guard_user_id")
      .joins("INNER JOIN sf_guard_user_profile ON sf_guard_user_profile.user_id = sf_guard_user.id")
      .where(sf_guard_user: { is_active: true, is_super_admin: false }, sf_guard_user_profile: { is_confirmed: true })
      .order(:username)
      .page(params[:page]).per(100)
  end

  # GET /users/1
  def show
  end
  
  # GET /users/:id/edit_permissions
  def edit_permissions

  end

  def add_permission
    SfGuardUserPermission.create!(permission_id: params[:permission].to_i, user_id: @user.sf_guard_user_id)
    redirect_to edit_permissions_user_path(@user.id),  notice: "Permission was successfully added."
  end

  def delete_permission
    SfGuardUserPermission.remove_permission(permission_id: params[:permission].to_i, user_id: @user.sf_guard_user_id)
    redirect_to edit_permissions_user_path(@user.id),  notice: "Permission was successfully deleted."    
  end

  def success
  end

  # DELETE /users/1
  # def destroy
  #   @user.destroy
  #   redirect_to users_url, notice: 'User was successfully destroyed.'
  # end

  def admin
    check_permission "admin"

    @users = User
      .includes(:groups)
      .joins("INNER JOIN sf_guard_user ON sf_guard_user.id = users.sf_guard_user_id")
      .joins("INNER JOIN sf_guard_user_profile ON sf_guard_user_profile.user_id = sf_guard_user.id")
      .where(sf_guard_user: { is_super_admin: false })
      .order("created_at DESC")
      .page(params[:page]).per(100)

    if params[:q]
      q = '%' + params[:q] + '%'
      @users = @users.where("sf_guard_user_profile.name_last LIKE ? OR sf_guard_user_profile.name_first LIKE ? OR users.username LIKE ? OR users.email LIKE ?", q, q, q, q)
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params[:user]
    end

    def permission_id
      params[:permission]
    end
end
