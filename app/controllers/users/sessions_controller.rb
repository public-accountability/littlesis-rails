# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]
  after_action :allow_chat_iframe, only: [:new, :create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # post /resource/sign_in
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

  # GET /resource/sign_out
  def destroy
    super
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  private

  def allow_chat_iframe
    response.headers['X-Frame-Options'] = "ALLOW-FROM #{APP_CONFIG['chat']['chat_url']}"
  end
end
