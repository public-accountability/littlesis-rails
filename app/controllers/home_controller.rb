# frozen_string_literal: true

class HomeController < ApplicationController
  include SpamHelper

  before_action :authenticate_user!,
                except: [:dismiss, :index, :flag, :token, :newsletter_signup, :pai_signup, :test]

  skip_before_action :verify_authenticity_token, only: [:pai_signup]

  # [list_id, 'translation_key' ]
  DOTS_CONNECTED_LISTS = [
    [41, 'paid_for_politicians'],
    [88, 'corporate_fat_cats'],
    [102, 'revolving_door_lobbyists'],
    [114, 'super_pacs'],
    [34, 'elite_think_tanks']
  ].freeze

  def dashboard
    @maps = current_user.network_maps.order(created_at: :desc).page(1).per(4)
  end

  # Sends CSRF token to browser extension
  def token
    if user_signed_in?
      render inline: '<%= csrf_meta_tags %>', layout: false
    else
      head :unauthorized
    end
  end

  # Turbo stream for partial dashboard_maps
  def dashboard_maps
    page = params[:page]&.to_i || 1
    maps = current_user.network_maps.order(created_at: :desc).page(page).per(4)
    render partial: 'dashboard_maps', locals: { maps: maps, page: page, maps_per_page: 4 }
  end

  def dismiss
    session[:dismissed_alerts] ||= []
    session[:dismissed_alerts] << params[:id]
  end

  def maps
  end

  def lists
  end

  def index
    redirect_to_dashboard_if_signed_in unless ['/home', '/database'].include?(request.env['PATH_INFO'])
    @dots_connected = dots_connected
    @carousel_entities = carousel_entities
    @stats = ExtensionRecord.data_summary
    @newsletter_signup = NewsletterSignupForm.new(email: current_user&.email)
  end

  def flag
    if request.post?
      @flag_form = FlagForm.new(flag_params)
      @flag_form.create_flag
      redirect_to home_dashboard_path, notice: 'Your flag message has been sent. Thank you!'
    else
      @flag_form = FlagForm.new(page: request.referer, email: current_user&.email)
    end
  end

  # Adds user newsletter and redirects back to home page.
  #
  # POST /home/newsletter_signup
  #
  def newsletter_signup
    form = NewsletterSignupForm.new(newsletter_signup_params)

    NewsletterSignupJob.perform_later(form.email, [:signup]) if form.valid?

    flash.notice = "Thank you! You've been added to our newsletter."
    redirect_to root_path
  end

  # Alternative method for signing up to our mailing list
  # POST /home/pai_signup
  def pai_signup
    return head :forbidden if likely_a_spam_bot

    RateLimiter.rate_limit "pai_signup_request_count_for_#{request.remote_ip}"

    unless Rails.env.development?
      NewsletterSignupJob.perform_later(params.fetch('email'), [:signup])
    end

    redirect_to 'https://news.littlesis.org', allow_other_host: true
  end

  def test
    head :ok
  end

  private

  def redirect_to_dashboard_if_signed_in
    return redirect_to home_dashboard_path if user_signed_in?
  end

  def carousel_entities
    return unless List.exists?(Rails.application.config.littlesis.fetch(:carousel_list_id))

    Rails.cache.fetch('home_controller_index_carousel_entities', expires_in: 2.hours) do
      List.find(Rails.application.config.littlesis.fetch(:carousel_list_id)).entities.to_a
    end
  end

  def dots_connected
    Rails.cache.fetch('dots_connected_count', expires_in: 2.hours) do
      (Person.count + Org.count).to_s.split('')
    end
  end

  def flag_params
    params.permit(:email, :page, :message).to_h
  end

  def newsletter_signup_params
    params.require(:newsletter_signup_form).permit(:email, :very_important_wink_wink)
  end
end
