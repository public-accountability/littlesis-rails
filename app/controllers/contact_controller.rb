# frozen_string_literal: true

class ContactController < ApplicationController
  include FormHcaptcha

  before_action -> { verify(params) }, only: :create

  def index
    @contact = ContactForm.new(
      name: current_user&.username,
      email: current_user&.email
    )
  end

  def create
    @contact = ContactForm.new(contact_params)

    if @contact.valid?
      NotificationMailer.contact_email(contact_params).deliver_later
      flash[:notice] = 'Your message has been sent. Thank you!'
      redirect_to action: :index
    else
      flash.now[:errors] = @contact.errors.full_messages
      render template: 'contact/index'
    end
  end

  private def contact_params
    params
      .require(:contact_form)
      .permit(
        :name,
        :email,
        :subject,
        :message,
        :very_important_wink_wink
      ).to_h.tap { |h| h.store(:user_signed_in, user_signed_in?) }
  end
end
