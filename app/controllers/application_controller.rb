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

  rescue_from 'ActiveRecord::RecordNotFound' do |exception|
    render "errors/not_found", status: 404
  end

  rescue_from ActionController::RoutingError do |exception|
    exit
  end

  def admins_only
    check_permission("admin")
  end

  def auth
    redirect_to "/login" unless user_signed_in?
  end

  def check_permission(name)
    raise Exceptions::PermissionError unless current_user.present? and (current_user.has_legacy_permission(name) or curent_user.has_legacy_permission("admin"))
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

  def prepopulate_note_from_params
    @note = Note.new
    default_body = []

    if params[:reply_to].present?
      if (@reply_to_note = Note.find(params[:reply_to])).present?
        default_body += @reply_to_note.all_users.collect { |u| "@" + u.username }
        default_body += @reply_to_note.groups.collect { |g| "@group:" + g.slug }
        @note.is_private if @reply_to_note.is_private
      end
    end

    if params[:user].present?
      default_body += ["@" + params[:user]]
    end

    # for legacy "write to this user" links
    if params[:user_id].present?
      user = User.where(sf_guard_user_id: params[:user_id]).first
      default_body += ["@" + user.username] if user.present?
    end

    if params[:group].present?
      default_body += ["@group:" + params[:group]]
    end

    if params[:entity_id].present?
      entity = Entity.find(params[:entity_id])
      default_body += [Note.entity_markup(entity)] if entity.present?
    end

    if params[:list_id].present?
      list = List.find(params[:list_id])
      default_body += [Note.list_markup(list)] if list.present?
    end

    @note.body_raw = default_body.uniq.join(" ") unless default_body.blank?
  end

  def ensure_entity_queue(key)
    session[:entity_queues] = {} unless session[:entity_queues].present?
    session[:entity_queues][key] = { entity_ids: [] } unless session[:entity_queues][key].present?
  end

  def set_entity_queue(key, entity_ids, list_id=nil)
    ensure_entity_queue(key)
    session[:entity_queues][key][:entity_ids] = entity_ids
    session[:entity_queues][key][:list_id] = list_id if list_id
    entity_ids
  end

  def next_entity_in_queue(key)
    ensure_entity_queue(key)
    remove_skipped_from_queue(key)
    session[:entity_queues][key][:entity_ids].shift
  end

  def entity_queue_count(key)
    ensure_entity_queue(key)
    session[:entity_queues][key][:entity_ids].count
  end

  def remove_skipped_from_queue(key)
    session[:entity_queues][key][:entity_ids] = QueueEntity.filter_skipped(key, session[:entity_queues][key][:entity_ids])
  end

  def skip_queue_entity(key, entity_id)
    QueueEntity.skip_entity(key, entity_id, current_user.id)
  end
end
