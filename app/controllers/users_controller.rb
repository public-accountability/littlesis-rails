class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit]
  before_action :authenticate_user!
  
  # GET /users
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
      @user = User.find_by_username(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params[:user]
    end
end
