class Users::SessionsController < Devise::SessionsController
# before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    store_location_for(:user, home_dashboard_path)
    super do |user|
      
      if Devise::TRUE_VALUES.include?(params['user']['remember_me'])
        cookies[:LittleSisRememberMe] = {
          value: SfGuardRememberKey.create_new_key_for_user(user, request.remote_ip),
          expires: 2.weeks.from_now
        }
      end
      
      session[:sf_user_id] = user.sf_guard_user.id
    end
  end

  # DELETE /resource/sign_out
  def destroy
    SfGuardRememberKey.delete_keys_for_user(current_user)
    if cookies[:LittleSis].present?
      Session.find_by(session_id: cookies[:LittleSis]).destroy
      cookies.delete(:LittleSis)
    end
    super
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
