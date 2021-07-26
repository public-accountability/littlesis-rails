# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ParamsHelper
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception, unless: -> { request.format.json? }

  before_action :set_paper_trail_whodunnit

  before_action :configure_permitted_parameters, if: :devise_controller?

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
    if params[:tab].present?
      redirect_to(concretize_tab_entity_path(e.merged_entity, tab: params.fetch(:tab)))
    else
      redirect_to(concretize_entity_path(e.merged_entity))
    end
  end

  def admins_only
    check_permission 'admin'
  end

  def auth
    redirect_to '/login' unless user_signed_in?
  end

  def block_restricted_user_access
    raise Exceptions::RestrictedUserError if current_user.restricted?
  end

  def check_permission(name)
    raise Exceptions::PermissionError unless current_user.present?
    raise Exceptions::RestrictedUserError if current_user.restricted?
    raise Exceptions::EditingDisabled if APP_CONFIG['noediting'] && !current_user.essential?
    raise Exceptions::PermissionError unless current_user.has_ability?(name)
  end

  # Array, Integer -> Void
  def block_unless_bulker(resources = [], limit = 0)
    # users who aren't admins or 'bulkers' may not create more than `limit` resources at a time
    if (resources.present? && resources.length > limit) && !(current_user.bulker? || current_user.admin?)
      raise Exceptions::UnauthorizedBulkRequest
    end
  end

  def not_found
    raise Exceptions::NotFoundError, request.path
  end

  def dismiss_alert(id)
    session[:dismissed_alerts] ||= []
    session[:dismissed_alerts] << id
  end

  def clear_dismissed_alerts
    session[:dismissed_alerts] = []
  end

  ##
  # merge
  #

  def merge_last_user(attrs)
    attrs.merge(last_user_id: current_user.id)
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

  def redirect_to_dashboard
    redirect_to home_dashboard_path
  end

  def render_html_not_found(exception)
    if request.format == :html
      render 'errors/not_found', status: :not_found
    else
      raise exception
    end
  end
end
