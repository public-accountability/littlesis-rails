class ErrorsController < ApplicationController

  PLACEHOLDERS = {
    description: "If sumbitting a bug report, describe with as much detail as you can what you were doing that caused the error.",
    reproduce: "How do you reproduce this bug. For example: \n 1) Navigate to the page /bug_report\n 2) Fill out the text box label description\n 3) Click submit button",
    expected: "What you expected or wished would happen"
  }.freeze

  def bug_report
  end

  def file_bug_report
    # NotificationMailer.bug_report_email(params).deliver_later
    flash.now[:notice] = 'Thank you for submitting a bug report and helping to improve LittleSis!'
    if user_signed_in?
      redirect_to home_dashboard_path
    else
      render 'bug_report'
    end
  end

  private

  def bug_report_params
    params.permit(:email, :type, :summary, :page, :description, :reproduce, :expected)
  end
  
end
