# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user,
                only: [:show, :edit_permissions, :add_permission, :delete_permission, :destroy, :restrict, :edits]
  before_action :authenticate_user!, except: [:success, :check_username]
  before_action :block_restricted_user_access
  before_action :user_or_admins_only, only: [:edits]
  before_action :admins_only, except: [:show, :edits, :success, :check_username]

  # rescue_from(UserAbilities::InvalidUserAbilityError) { head :bad_request }

  # GET /users/:username
  def show
  end

  # GET /users/:username/edits
  def edits
    @edits = @user.recent_edits(page_param)
  end

  # GET /users/check_username
  def check_username
    render json: { username: params.require(:username),
                   valid: User.valid_username?(params.require(:username)) }
  end

  # def image
  #   @user = User.find(params[:id])
  #   @image = Image.new
  # end

  # def upload_image
  #   if uploaded = image_params[:file]
  #     filename = Image.random_filename(File.extname(uploaded.original_filename))
  #     src_path = Rails.root.join('tmp', filename).to_s
  #     open(src_path, 'wb') do |file|
  #       file.write(uploaded.read)
  #     end
  #   else
  #     src_path = image_params[:url]
  #   end

  #   @image = Image.new_from_url(src_path)
  #   @image.user = @user

  #   if @image.save
  #     redirect_to image_user_path(@user), notice: 'Image was successfully created.'
  #   else
  #     render action: 'image'
  #   end
  # end

  # GET /users/:id/edit_permissions
  def edit_permissions
  end

  def add_permission
    @user.add_ability!(edit_permission_param)
    redirect_to edit_permissions_user_path(@user.id), notice: 'Permission was successfully added.'
  end

  def delete_permission
    @user.remove_ability!(edit_permission_param)
    redirect_to edit_permissions_user_path(@user.id), notice: 'Permission was successfully deleted.'
  end

  def success
  end

  # DELETE /users/1/destroy
  def destroy
    if @user.admin?
      return redirect_to admin_users_path, notice: 'You can\'t delete an admin user'
    else
      Entity.where(last_user_id: @user.id).update_all(last_user_id: 1)
      Relationship.where(last_user_id: @user.id).update_all(last_user_id: 1)
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
               .includes(:user_profile)
               .where.not(role: :system)
               .where(User.matches_username_or_email(params[:q]))
               .order('created_at DESC')
               .page(params[:page] || 1)
               .per(50)
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


  def edit_permission_param
    params.require(:permission).to_sym.tap do |new_ability|
      UserAbilities.assert_valid_ability(new_ability)
    end
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

  def page_param
    if params[:page].nil?
      1
    else
      params[:page].to_i
    end
  end

  def user_or_admins_only
    raise Exceptions::PermissionError unless (current_user == @user) || current_user.admin?
  end
end
