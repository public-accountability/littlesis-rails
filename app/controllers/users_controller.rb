class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit_permissions, :add_permission, :delete_permission, :destroy, :restrict]
  before_action :authenticate_user!, except: [:success]
  before_filter :admins_only, except: [:show, :restrict, :success]

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
    @maps = @user.network_maps.order("created_at DESC, id DESC")
    @groups = @user.groups.includes(:campaign).order(:name)
    @lists = @user.lists.order("created_at DESC, id DESC")
    @recent_updates = @user.edited_entities.includes(last_user: :user).order("updated_at DESC").limit(10)
    @permissions = @user.permissions.instance_variable_get(:@sf_permissions)
    @all_permissions = Permissions::ALL_PERMISSIONS
  end

  def image
    @user = User.find(params[:id])
    @image = Image.new
  end

  def upload_image
    if uploaded = image_params[:file]
      filename = Image.random_filename(File.extname(uploaded.original_filename))      
      src_path = Rails.root.join('tmp', filename).to_s
      open(src_path, 'wb') do |file|
        file.write(uploaded.read)
      end
    else
      src_path = image_params[:url]
    end

    @image = Image.new_from_url(src_path)
    @image.user = @user

    if @image.save
      redirect_to image_user_path(@user), notice: 'Image was successfully created.'
    else
      render action: 'image'
    end
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

  # DELETE /users/1/destroy
  def destroy
    if @user.has_legacy_permission('admin')
      return redirect_to admin_users_path, notice: 'You can\'t delete an admin user'
    else
      SfGuardUserPermission.where(user_id: @user.sf_guard_user_id).map(&:permission_id).each do |permission_id|
        SfGuardUserPermission.remove_permission(permission_id: permission_id, user_id: @user.sf_guard_user_id)
      end
      @user.sf_guard_user.update(is_deleted: true)
      Entity.where(last_user_id: @user.sf_guard_user_id).update_all(last_user_id: 1)
      Relationship.where(last_user_id: @user.sf_guard_user_id).update_all(last_user_id: 1)
      @user.destroy
      redirect_to admin_users_path, notice: 'Successfully deleted the user'
    end
  end

  def restrict
    if @user.admin?
      redirect_to admin_users_path, notice: 'You can\'t restrict an admin user'
    elsif restrict_params == 'RESTRICT'
      @user.update(is_restricted: true)
      redirect_to admin_users_path, notice: "Successfully restricted #{@user.username}"
    elsif restrict_params == 'PERMIT'
      @user.update(is_restricted: false)
      redirect_to admin_users_path, notice: "Successfully removed restrictions from #{@user.username}"
    else
      redirect_to admin_users_path, notice: 'Incorrect paramters'
    end
  end

  def admin
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

  def set_user
    if params[:id].present?
      @user = User.find(params[:id])
    elsif params[:username].present?
      if params[:username].scan(/^[0-9]+$/).present?
        @user = User.find(params[:username])
      else
        @user = User.find_by_username!(params[:username])
      end
    else
      raise Exceptions::NotFoundError
    end
  end

  # Only allow a trusted parameter "white list" through.
  def user_params
    params[:user]
  end

  def permission_id
    params[:permission]
  end

  def restrict_params
    Rails.logger.warn params.inspect
    params[:status].try(:upcase)
  end

  def image_params
    params.require(:image).permit(
      :file, :url
    )
  end
end
