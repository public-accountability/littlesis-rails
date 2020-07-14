# frozen_string_literal: true

class HomeController < ApplicationController
  include SpamHelper

  before_action :authenticate_user!,
                except: [:dismiss, :index, :contact, :flag, :token, :newsletter_signup, :pai_signup]

  skip_before_action :verify_authenticity_token, only: [:pai_signup]

  # [list_id, 'title' ]
  DOTS_CONNECTED_LISTS = [
    [41, 'Paid for politicians'],
    [88, 'Corporate fat cats'],
    [102, 'Revolving door lobbyists'],
    [114, 'Secretive Super PACs'],
    [34, 'Elite think tanks']
  ].freeze

  def dashboard
    @user_dashboard = UserDashboardPresenter.new(current_user,
                                                 map_page: params[:map_page],
                                                 list_page: params[:list_page])
  end

  # Sends CSRF token to browser extension
  def token
    if user_signed_in?
      render :inline => "<%= csrf_meta_tags %>"
    elsif Rails.env.development?
      render :inline => '<meta name="csrf-param" content="authenticity_token" /><meta name="csrf-token" content="CSRF-TOKEN-FOR-TESTING" />'
    else
      head :unauthorized
    end
  end

  def dismiss
    dismiss_alert(params[:id])
    render json: { id: params[:id] }
  end

  def maps
  end

  def lists
  end

  def index
    redirect_to_dashboard_if_signed_in unless request.env['PATH_INFO'] == '/home'
    @newsletter_thankyou = params[:nlty].present?
    @dots_connected = dots_connected
    @carousel_entities = carousel_entities
    @stats = ExtensionRecord.data_summary
  end

  def contact
    if request.post?
      if contact_params[:name].blank?
        flash.now[:alert] = "Please enter in your name"
        @message = params[:message]
      elsif contact_params[:email].blank?
        flash.now[:alert] = 'Please enter in your email'
        @message = params[:message]
      elsif contact_params[:message].blank?
        flash.now[:alert] = "Don't forget to write a message!"
        @name = params[:name]
      else
        if likely_a_spam_bot
          flash.now[:alert] = ErrorsController::YOU_ARE_SPAM
        elsif user_signed_in? || verify_math_captcha
          NotificationMailer.contact_email(contact_params).deliver_later # send_mail
          flash.now[:notice] = 'Your message has been sent. Thank you!'
        else
          flash.now[:alert] = 'Incorrect solution to the math problem. Please try again.'
        end
      end
    end
  end

  def flag
    if request.post?
      if flag_params[:email].blank?
        flash.now[:alert] = 'Please enter in your email'
        @message = flag_params[:message]
        @name = flag_params[:name]
        @referrer = flag_params[:url]
      elsif flag_params[:message].blank?
        flash.now[:alert] = "Don't forget to write a message!"
        @name = flag_params[:name]
        @referrer = flag_params[:url]
      else
        NotificationMailer.flag_email(flag_params.to_h).deliver_later
        flash.now[:notice] = 'Your message has been sent. Thank you!'
      end
    else
      @referrer = request.referrer
    end
  end

  # Adds user newsletter and redirects back to home page.
  #
  # POST /home/newsletter_signup
  #
  def newsletter_signup
    unless likely_a_spam_bot || Rails.env.development?
      NewsletterSignupJob.perform_later params.fetch('email'), 'newsletter'
    end
    redirect_to root_path(nlty: 'yes')
  end

  # Signup an email address to the PAI newsletter
  # redirects to 'referer' if present or 'https://news.littlesis.org'
  #
  # POST /home/pai_signup
  def pai_signup
    return head :forbidden if likely_a_spam_bot

    pai_signup_ip_limit(request.remote_ip)

    signup_type = params[:tag]&.downcase.eql?('press') ? 'press' : 'pai'

    NewsletterSignupJob.perform_later params.fetch('email'), signup_type unless Rails.env.development?

    if request.headers['referer'].blank?
      redirect_to 'https://news.littlesis.org'
    else
      redirect_to request.headers['referer']
    end
  end

  private

  def pai_signup_ip_limit(ip)
    ip_cache_key = "pai_signup_request_count_for_#{ip}"

    if Rails.cache.read(ip_cache_key).nil?
      Rails.cache.write(ip_cache_key, 1, :expires_in => 60.minutes)
    else
      count = Rails.cache.read(ip_cache_key) + 1
      if count >= 5
        Rails.logger.warn "#{ip} has submitted too many requests this hour!"
        raise Exceptions::PermissionError
      else
        Rails.cache.write(ip_cache_key, count, :expires_in => 60.minutes)
      end
    end
  end

  def redirect_to_dashboard_if_signed_in
    if user_signed_in?
      return redirect_to home_dashboard_path
    end
  end

  def carousel_entities
    Rails.cache.fetch('home_controller_index_carousel_entities', expires_in: 2.hours) do
      List.find(APP_CONFIG.fetch('carousel_list_id')).entities.to_a
    end
  end

  def dots_connected
    Rails.cache.fetch('dots_connected_count', expires_in: 2.hours) do
      (Person.count + Org.count).to_s.split('')
    end
  end

  def contact_params
    params.permit(:email, :subject, :name, :message).to_h
  end

  def flag_params
    params.permit(:email, :url, :name, :message)
  end
end
