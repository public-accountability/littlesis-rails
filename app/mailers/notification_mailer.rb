# frozen_string_literal: true

class NotificationMailer < ApplicationMailer
  DEFAULT_TO = APP_CONFIG['notification_to']

  def contact_email(params)
    @name = params[:name]
    @email = params[:email]
    @message = params[:message]
    mail(to: DEFAULT_TO,
         subject: "Contact Us: #{params[:subject]}",
         reply_to: @email)
  end

  def flag_email(user_flag)
    @email = user_flag.email
    @message = user_flag.justification
    @url = user_flag.page
    mail(to: DEFAULT_TO, subject: 'Flag for Review', reply_to: @email)
  end

  def signup_email(user)
    @user = user
    @profile = user.user_profile
    mail(to: DEFAULT_TO,
         subject: "New User Signup: #{user.username}")
  end

  def bug_report_email(params)
    params.default = ''
    subject = "Bug Report: #{params['summary'].truncate(20)}"
    @params = params
    mail(to: DEFAULT_TO, subject: subject)
  end

  def tag_request_email(user, params)
    @user = user
    @params = params
    mail(to: DEFAULT_TO,
         subject: "Tag Request: #{params['tag_name']}",
         reply_to: user.email)
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

  def list_deletion_request_email(deletion_request)
    @deletion_request = deletion_request
    mail(
      to: DEFAULT_TO,
      subject: "List deletion request received for #{deletion_request.list.name}",
      reply_to: deletion_request.user.email
    )
  end

  def image_deletion_request_email(image_deletion_request)
    @image_deletion_request = image_deletion_request
    mail(to: DEFAULT_TO,
         subject: "Image deletion request received (#{image_deletion_request.id})",
         reply_to: image_deletion_request.user.email)
  end
end
