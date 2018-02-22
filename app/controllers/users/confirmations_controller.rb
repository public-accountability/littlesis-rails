class Users::ConfirmationsController < Devise::ConfirmationsController
  # GET /resource/confirmation/new
  # def new
  #   super
  # end

  # POST /resource/confirmation
  # def create
  #   super
  # end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    super do |user|
      # send welcome email to user - views/user_mailer/welcome_email
      if user.errors.empty?
        UserMailer.welcome_email(user).deliver_later
        user.create_default_permissions

        # If the user's request is from a spamy ip address then automatically restrict the user
        # and don't create a chat account
        if IpBlocker.restricted?(request.remote_ip)
          user.update(is_restricted: true)
        else
          # TODO: combine these into a unifed "post-signup" method
          user.delay.create_chat_account
          NotificationMailer.signup_email(user).deliver_later
          NewsletterSignupJob.perform_later(user)
        end

      end
    end
  end

  protected

  # The path used after resending confirmation instructions.
  # def after_resending_confirmation_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  # The path used after confirmation.
  def after_confirmation_path_for(resource_name, resource)
    home_dashboard_path
  end

end
