class NotificationMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)
  default from: APP_CONFIG['notification_email']
  DEFAULT_TO = APP_CONFIG['notification_to']

  SMTP_OPTIONS = { user_name: APP_CONFIG['notification_user_name'], password: APP_CONFIG['notification_password'] }
  

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
         reply_to: @email,
         delivery_method_options: SMTP_OPTIONS)
  end

  def signup_email(user)
    @user = user
    @profile = user.sf_guard_user_profile
    mail(to: DEFAULT_TO, subject: "New User Signup: #{user.username}", delivery_method_options: SMTP_OPTIONS)
  end

  def bug_report_email(params)
    params.default = ''
    subject = "Bug Report: #{params['summary'].truncate(20)}"
    @params = params
    mail(to: DEFAULT_TO, subject: subject, method_options: SMTP_OPTIONS)
  end

  def tag_request_email(user, params)
    @user = user
    @params = params
    mail(to: DEFAULT_TO,
         subject: "Tag Request: #{params['tag_name']}",
         reply_to: user.email,
         method_options: SMTP_OPTIONS)
  end

  def merge_request_email(merge_request)
    @merge_request = merge_request
    mail(to: DEFAULT_TO,
         subject: "Merge request received for #{merge_request.source.name}",
         reply_to: merge_request.user.email)
  end

  def deletion_request_email(deletion_request)
    @deletion_request = deletion_request
    mail(to: DEFAULT_TO,
         subject: "Deletion request received for #{deletion_request.entity.name}",
         reply_to: deletion_request.user.email)
  end
end
