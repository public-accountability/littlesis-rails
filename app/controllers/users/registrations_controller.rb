# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    super
  end

  # "resource" is the generic term used in devise. 'resource' here
  #  are just instances of User. (ziggy 10-27-16)
  # POST /resource
  def create
    @signup_errors = []
    build_resource(user_params)

    # check recaptcha
    unless verify_recaptcha
      @signup_errors << 'The recaptcha failed to verify'
      reset_signup_session
      return render 'new'
    end

    resource.user_profile.assign_attributes user_profile_params

    ApplicationRecord.transaction do
      begin
        resource.save!
      rescue ActiveRecord::StatementInvalid
        raise
      rescue
        raise ActiveRecord::Rollback
      end
    end

    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        return respond_with resource, location: after_sign_up_path_for(resource)
      else
        # set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        return respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else

      if resource.errors[:email].include?('has already been taken')
        @signup_errors << 'The email address you provided already has an account'
      end

      if resource.errors[:username].include?('has already been taken')
        @signup_errors << "The username -- #{resource.username} -- has already been taken"
      end

      if @signup_errors.empty?
        @signup_errors << 'A computer error occured! Please contact admin@littlesis.org'
      end

      reset_signup_session
      return render 'new'
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
  def update
    super
  end

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

  def build_resource(hash = nil)
    # self.resource = resource_class.new_with_session(hash || {}, session)
    self.resource = User.new(hash)
    self.resource.build_user_profile
  end

  def user_params
    params
      .require(:user)
      .permit(:username, :email, :password, :password_confirmation, :newsletter, :map_the_power)
  end

  def user_profile_params
    params
      .require(:user)
      .require(:user_profile_attributes)
      .permit(:name_first, :name_last, :location, :reason)
      .to_h
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
    devise_parameter_sanitizer.permit(:account_update, keys: [:username])
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  # end

  private

  def reset_signup_session
    clean_up_passwords resource
    set_minimum_password_length
  end
end
