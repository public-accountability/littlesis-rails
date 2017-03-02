class NotificationMailer < ApplicationMailer
  default from: APP_CONFIG['notification_email']

  SMTP_OPTIONS = { user_name: APP_CONFIG['notification_user_name'], password: APP_CONFIG['notification_password'] }
  DEFAULT_TO = APP_CONFIG['notification_to']

  def contact_email(params)
    @name = params[:name]
    @email = params[:email]
    @message = params[:message]
    mail(to: DEFAULT_TO,
         subject: "Contact Us: #{params[:subject]}",
         reply_to: @email,
         delivery_method_options: SMTP_OPTIONS)
  end

  def flag_email(params)
    @name = params.fetch('name', '')
    @email = params.fetch('email')
    @message = params.fetch('message')
    @url = params.fetch('url')
    mail(to: DEFAULT_TO,
         subject: 'Flag for Review',
         delivery_method_options: SMTP_OPTIONS)
  end

  def signup_email(user)
    @user = user
    @profile = user.sf_guard_user_profile
    mail(to: DEFAULT_TO, subject: "New User Signup: #{user.username}", delivery_method_options: SMTP_OPTIONS)
  end
end
