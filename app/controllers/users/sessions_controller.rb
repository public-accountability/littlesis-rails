# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # post /resource/sign_in
  # def create
  #   super
  # end

  # GET /resource/sign_out
  # def destroy
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  # Send user to home dashboard
  # https://github.com/heartcombo/devise/blob/v4.9.4/lib/devise/controllers/helpers.rb#L171
  def signed_in_root_path(resource_or_scope)
    home_dashboard_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
end
