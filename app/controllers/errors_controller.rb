# frozen_string_literal: true

class ErrorsController < ApplicationController
  PLACEHOLDERS = {
    description: "If submitting a bug report, describe with as much detail as you can what you were doing that caused the error.",
    reproduce: "How do you reproduce this bug. For example: \n 1) Navigate to the page /bug_report\n 2) Fill out the text box labeled description\n 3) Click submit button",
    expected: "What you expected or wished would happen"
  }.freeze

  THANK_YOU_NOTICE = 'Thank you for submitting a bug report and helping to improve LittleSis!'
  YOU_ARE_SPAM = "Please don't submit spam to LittleSis. Contact us if you think this is an error."

  def bug_report
  end

  def file_bug_report
    if user_signed_in?
      NotificationMailer.bug_report_email(bug_report_params).deliver_later
      redirect_to home_dashboard_path, notice: THANK_YOU_NOTICE
    else
      if SpamDetector.bug_report?(bug_report_params)
        flash.now[:notice] = YOU_ARE_SPAM
      else
        NotificationMailer.bug_report_email(bug_report_params).deliver_later
        flash.now[:notice] = THANK_YOU_NOTICE
      end
      render 'bug_report'
    end
  end

  private

  def bug_report_params
    params.permit(:email, :type, :summary, :page, :description, :reproduce, :expected).to_h
  end
end
