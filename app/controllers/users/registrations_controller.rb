# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  include SpamHelper
  helper_method :math_captcha

  # before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # GET /join
  def new
    super do |user|
      user.build_user_profile
    end
  end

  def create
    if verify_math_captcha
      super do |user|
        @signup_errors = if user.persisted? && user.valid?
                           []
                         else
                           user.errors.full_messages
                         end
      end
    else
      @signup_errors = ['Failed to solve the math problem']
      self.resource = resource_class.new sign_up_params
      respond_with_navigational(resource) { render :new }
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

  # PUT /users/settings
  def update_settings
    authenticate_scope!

    resource.settings.update(user_settings_params)
    resource.save!

    redirect_to action: :edit
  end

  # GET /users/edit
  # def edit
  #   super
  # end

  # PUT /users
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

  def sign_up_params
    params
      .require(:user)
      .permit(:username, :email, :password, :password_confirmation, :newsletter, :map_the_power,
              :user_profile_attributes => [:name_first, :name_last, :location, :reason])
  end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    join_success_path
  end

  def after_update_path_for(resource)
    home_dashboard_path
  end

  # The path used after sign up for inactive accounts.
  def after_inactive_sign_up_path_for(resource)
    join_success_path
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update,
                                      keys: [:username, settings: [:oligrapher_beta]])
  end

  def user_settings_params
    params
      .require(:settings)
      .permit(*UserSettings::DEFAULTS.keys)
      .to_h
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  # end
end
