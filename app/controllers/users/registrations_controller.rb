# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # GET /join
  def new
    super do |user|
      user.build_user_profile
    end
  end

  # POST /join
  def create
    if NewUserForm.new(math_captcha_params).valid?
      super do |user|
        flash.now[:errors] = user.errors.full_messages unless user.persisted? && user.valid?
      end
    else
      flash.now[:errors] = ['Failed to solve the math problem']
      self.resource = resource_class.new sign_up_params
      respond_with_navigational(resource) { render :new }
    end
  end

  # PUT /users/settings
  def update_settings
    authenticate_scope!

    resource.settings.update(user_settings_params)
    resource.save!

    redirect_to edit_user_registration_path
  end

  # GET /users/edit
  # def edit
  #   super
  # end

  # PUT /users
  # def update
  #   super
  # end

  # GET /users/delete
  def delete
    authenticate_scope!
  end

  # DELETE /resource
  def destroy
    authenticate_scope!
    raise Exceptions::PermissionError unless resource.valid_password?(params[:current_password])
    Rails.logger.warn "User #{resource.username} has scheduled their account to be deleted"
    DeleteUserJob.set(wait: 12.hours).perform_later(resource.id)
    sign_out(resource_name)
    redirect_to "/"
  end

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
      .permit(:username, :email, :password, :password_confirmation, :newsletter,
              :user_profile_attributes => [:name, :location, :reason])
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

  def user_settings_params
    params
      .require(:settings)
      .permit(*UserSettings::DEFAULTS.keys)
      .to_h
  end

  def math_captcha_params
    params
      .require(:math_captcha)
      .permit(
        :math_captcha_first,
        :math_captcha_second,
        :math_captcha_operation,
        :math_captcha_answer
    )
  end
end
