class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :admins_only if Lilsis::Application.config.admins_only

  rescue_from 'Exceptions::PermissionError' do |exception|
  	render "errors/permission", status: 403
  end

  rescue_from 'Exceptions::NotFoundError' do |exception|
    render "errors/not_found", status: 404
  end

  def admins_only
    check_permission("admin")
  end

  def auth
    redirect_to "/login" unless user_signed_in?
  end

  def check_permission(name)
    raise Exceptions::PermissionError unless current_user.present? and current_user.has_legacy_permission(name)
  end

  def not_found
    raise Exceptions::NotFoundError
  end

  def dismiss_alert(id)
    session[:dismissed_alerts] ||= []
    session[:dismissed_alerts] << id
  end

  def clear_dismissed_alerts
    session[:dismissed_alerts] = []
  end
end
