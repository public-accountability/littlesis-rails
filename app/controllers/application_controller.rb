# frozen_string_literal: true

class ApplicationController < ActionController::Base
  AVAILABLE_LOCALES = HTTP::Accept::Languages::Locales.new(["en", "es"]).freeze
  BULK_MAXIMUM = 100

  include ParametersHelper
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception, prepend: true  #, unless: -> { request.format.json? }

  before_action :set_paper_trail_whodunnit

  before_action :configure_permitted_parameters, if: :devise_controller?

  around_action :switch_locale

  rescue_from Exceptions::PermissionError do
    render 'errors/permission', layout: 'application', status: :forbidden
  end

  rescue_from Exceptions::RestrictedUserError do
    redirect_to home_dashboard_path, notice: <<~NOTICE
      Your account has been restricted. This might be because we think you are posting spam. If that's a mistake, please contact us
    NOTICE
  end

  rescue_from Exceptions::UserCannotEditError do
    redirect_to home_dashboard_path, notice: <<~NOTICE
      In order to prevent abuse, new users are restricted from editing for the first hour.
      We are sorry for the inconvenience. Please contact us if you believe that you are getting this message by mistake.
    NOTICE
  end

  rescue_from Exceptions::NotFoundError do |exception|
    render_html_not_found(exception)
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render_html_not_found(exception)
  end

  rescue_from ActionController::RoutingError do |exception|
    raise if Rails.env.development?

    render_html_not_found(exception)
  end

  rescue_from Exceptions::UnauthorizedBulkRequest do |exception|
    # for use only with JSON requests
    render json: { errors: ['title' => exception.message] }, status: :unauthorized
  end

  rescue_from Exceptions::MergedEntityError do |e|
    tab = params[:active_tab] || params[:tab]
    if tab.present?
      redirect_to(concretize_profile_entity_path(e.merged_entity, active_tab: tab))
    else
      redirect_to(concretize_entity_path(e.merged_entity))
    end
  end

  rescue_from Exceptions::RateLimitExceededError do |e|
    render json: { status: 'error', message: 'Too Many Requests' }, status: :too_many_requests
  end

  def admins_only
    raise Exceptions::PermissionError unless current_user&.admin?
  end

  def auth
    redirect_to '/login' unless user_signed_in?
  end

  def block_restricted_user_access
    raise Exceptions::RestrictedUserError if current_user.restricted?
  end

  # raises exception if current_user does not correct abiliity
  # see User::Role for list of abilities
  # @param name [String, Symbol] name of ability
  def check_ability(name)
    raise Exceptions::NotSignedInError if current_user.nil?
    raise Exceptions::RestrictedUserError if current_user.restricted?
    raise Exceptions::PermissionError unless current_user.role.include?(name.to_sym)
  end

  def current_user_can_edit?
    raise Exceptions::PermissionError unless current_user&.can_edit?
  end

  # users who aren't admins or 'bulkers' may not create more than `limit` resources at a time
  # @param resources [Array]
  # @param limit [Integer]
  def block_unless_bulker(resources = [], limit = 0)
    return if resources.blank?

    if resources.length > BULK_MAXIMUM || (resources.length > limit && current_user.role.exclude?(:bulk_upload))
      raise Exceptions::UnauthorizedBulkRequest
    end
  end

  def not_found
    raise Exceptions::NotFoundError
  end

  protected

  def set_page
    @page = params[:page].presence&.to_i || 1
  end

  def set_entity(skope = :itself)
    @entity = Entity.find_with_merges(id: params[:id], skope: skope)
  end

  def set_cache_control(time = 1.hour)
    expires_in(time, public: true, must_revalidate: true)
  end

  def value_for_param(param, default_value, transform = :itself)
    params[param].present? ? params[param].send(transform) : default_value
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:about_me])
  end

  def api_request?
    request_type && request_type == 'API'
  end

  def request_type
    request.headers['Littlesis-Request-Type']
  end

  def chrome_extension_request?
    request.headers['origin'] == "chrome-extension://" + Rails.application.config.littlesis[:chrome_extension_id]
  end

  def redirect_to_dashboard
    redirect_to home_dashboard_path
  end

  def render_html_not_found(exception)
    if request.format == :html
      render 'errors/not_found', status: :not_found, layout: 'application'
    else
      raise exception
    end
  end

  private

  def switch_locale(&action)
    locale = params[:locale] || current_user&.settings&.language || locale_from_header || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  def locale_from_header
    if request.headers['Accept-Language']
      (AVAILABLE_LOCALES & HTTP::Accept::Languages.parse(request.headers['Accept-Language'])).first
    end
  rescue HTTP::Accept::ParseError
    nil
  end
end
