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
      if user.errors.empty?
        user.create_default_permissions
        # send welcome email to user - views/user_mailer/welcome_email
        UserMailer.welcome_email(user).deliver_later
        # add to action network mailing list
        NewsletterSignupJob.perform_later(user) if user.newsletter

        # User Sign Up to admin@littlesis.org
        # NotificationMailer.signup_email(user).deliver_later

        # if IpBlocker.restricted?(request.remote_ip)
        #   user.update(is_restricted: true)
        # end
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
