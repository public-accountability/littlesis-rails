class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]  

  HOME_NETWORK_IDS = [
    ['United States', 79],
    ['Buffalo', 78],
    ['United Kingdom', 96],
    ['Baltimore', 132],
    ['New York State', 133],
    ['Oakland', 198]
  ]

  # GET /resource/sign_up
  def new
    super
  end

  # "resource" is the generic term used in devise. 'resource' here
  #  are just instances of User. (ziggy 10-27-16)
  # POST /resource
  def create
    build_resource(user_params)
    resource.sf_guard_user.username = resource.email
    resource.sf_guard_user.sf_guard_user_profile.assign_attributes(sf_profile_params)
    
    if resource.sf_guard_user.valid? and resource.sf_guard_user.sf_guard_user_profile.valid?
      resource.sf_guard_user.save
      resource.sf_guard_user_profile.save
      resource.save
      if resource.persisted?
        resource.create_default_permissions
        if resource.active_for_authentication?
          set_flash_message! :notice, :signed_up
          sign_up(resource_name, resource)
          return respond_with resource, location: after_sign_up_path_for(resource)
        else
          # set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
          expire_data_after_sign_in!
          return respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      return respond_with resource
    end
  end

  # post /users/api_token
  def api_token
    # see https://github.com/plataformatec/devise/blob/master/app/controllers/devise/registrations_controller.rb
    authenticate_scope!

    if params[:api] == 'generate'
      current_user.create_api_token! if current_user.api_token.blank?
    end

    if params[:api] == 'reset'
      if current_user.api_token.updated_at < 1.day.ago
        current_user.api_token.reset!
      else
        return head :not_acceptable
      end
    end

    render action: :edit
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  def build_resource(hash=nil)
    # self.resource = resource_class.new_with_session(hash || {}, session)
    self.resource = User.new(hash)
    self.resource.sf_guard_user = SfGuardUser.new
    self.resource.sf_guard_user.sf_guard_user_profile = SfGuardUserProfile.new(is_confirmed: true)
  end

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :default_network_id, :newsletter)
  end

  def sf_profile_params
    sf_params = params.require(:user).permit(:email, :username, :default_network_id, sf_guard_user_profile: [:name_first, :name_last, :reason] )
    sf_params[:sf_guard_user_profile].merge(
      "email"=>sf_params[:email], 
      "public_name"=>sf_params[:username],
      "home_network_id"=>sf_params[:default_network_id]
    )
  end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    home_dashboard_path
  end

  def after_update_path_for(resource)
    home_dashboard_path
  end

  # The path used after sign up for inactive accounts.
  def after_inactive_sign_up_path_for(resource)
    join_success_path
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  # end
 
end
