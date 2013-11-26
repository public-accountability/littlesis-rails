class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  def index
    auth
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

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to @user, notice: 'User was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
    redirect_to users_url, notice: 'User was successfully destroyed.'
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
end
