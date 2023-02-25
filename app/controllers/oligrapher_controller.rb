# frozen_string_literal: true

class OligrapherController < ApplicationController
  AUTHENITICATED_ACTIONS = %i[new create update editors confirm_editor lock release_lock clone destroy featured all].freeze
  SEARCH_API_ACTIONS = %i[find_nodes find_connections get_edges get_interlocks].freeze

  before_action :set_cors_header, only: SEARCH_API_ACTIONS
  before_action :authenticate_user!, only: AUTHENITICATED_ACTIONS
  before_action :block_restricted_user_access, only: AUTHENITICATED_ACTIONS
  before_action :admins_only, only: %i[featured all admin_destroy].freeze
  before_action :set_map, only: %i[update editors confirm_editor show lock release_lock clone destroy embedded screenshot featured admin_destroy].freeze
  before_action :check_owner, only: %i[editors destroy].freeze
  before_action :enforce_slug, only: %i[show].freeze

  rescue_from ActiveRecord::RecordNotFound, with: :map_not_found
  rescue_from Exceptions::PermissionError, with: :map_not_found
  rescue_from Exceptions::RestrictedUserError, with: -> { head :forbidden }

  # Explore Maps Page
  def index
    respond_to do |format|
      format.html do
        render "index", layout: "application"
      end
      format.json do
        expires_in 6.hours, :public => true
        render :json => NetworkMap.index_maps
      end
    end
  end

  # Search
  def search
    render "search", layout: "application"
  end

  # stimulus partial for search
  def perform_search
    @query = params[:query]&.strip

    if @query.present?
      current_user_id = current_user.id if user_signed_in? && params[:personal_search]
      @search_results = OligrapherSearchService.run(@query, user_id: current_user_id)
    end

    render partial: 'search_results'
  end

  # Main Oligrapher page
  def show
    check_private_access
    @is_pending_editor = (current_user && @map.has_pending_editor?(current_user))
    # use_beta = current_user && current_user.settings.oligrapher_beta
    @oligrapher_javascript_path = Oligrapher.javascript_path(v4: @map.v4?)
    @oligrapher_css_path = Oligrapher.css_path(v4: @map.v4?)
    @configuration = Oligrapher.configuration(@map, current_user: current_user)
    render 'oligrapher/oligrapher', layout: 'oligrapher'
  end

  # Embedded View (used often in iframe)
  def embedded
    check_private_access
    @configuration = Oligrapher.configuration(@map, current_user: current_user, embed: true)
    @oligrapher_javascript_path = Oligrapher.javascript_path(v4: @map.v4?)
    @oligrapher_css_path = Oligrapher.css_path(v4: @map.v4?)
    response.headers.delete('X-Frame-Options')
    render "embedded", layout: 'embedded_oligrapher'
  end

  # Create new map
  def new
    # use_beta = current_user.settings.oligrapher_beta
    @map = NetworkMap.new(title: 'Untitled Map',
                          user: current_user,
                          oligrapher_commit: Rails.application.config.littlesis.oligrapher_commit
                          # oligrapher_commit: use_beta ? Rails.application.config.littlesis.oligrapher_beta : Rails.application.config.littlesis.oligrapher_commit
                         )
    @configuration = Oligrapher.configuration(@map, current_user: current_user)
    @oligrapher_javascript_path = Oligrapher.javascript_path(v4: @map.v4?)
    @oligrapher_css_path = Oligrapher.css_path(v4: @map.v4?)
    render 'oligrapher/new', layout: 'oligrapher'
  end

  def screenshot
    check_private_access

    if @map.screenshot_exists?
      expires_in 2.minutes, :public => true
      render file: @map.screenshot_path, layout: false
    else
      render file: "#{Rails.root}/app/assets/images/netmap-org.png", layout: false
    end
  end

  # POST /oligrapher
  #  { graph_data: {...}, attributes: { title, description, is_private, is_cloneable } }
  def create
    map = NetworkMap.new(new_oligrapher_params)

    if map.validate
      map.save!
      render json: { redirect_url: oligrapher_path(map) }
    else
      render json: map.errors, status: :bad_request
    end
  end

  def update
    raise Exceptions::PermissionError unless @map.can_edit?(current_user)
    @map.assign_attributes(oligrapher_params)

    if @map.validate
      @map.save!
      @configuration = Oligrapher.configuration(@map, current_user: current_user)
      render json: @configuration
    else
      render json: @map.errors, status: :bad_request
    end
  end

  def featured
    result = @map.update_columns(is_featured: !@map.is_featured)
    status = result ? :ok : :internal_server_error
    render json: { status: status, is_featured: @map.is_featured }, status: status
  end

  # Action Endpoints - API requests from Oligrapher

  # two actions { editor: { action: add | remove, username: <username> } }
  def editors
    action = params.require(:editor).require(:action).downcase
    username = params.require(:editor).require(:username)

    unless %w[add remove].include? action
      raise Exceptions::LittleSisError, "Invalid oligrapher editor action: #{action}"
    end

    unless (editor = User.find_by(username: username))
      raise Exceptions::LittleSisError, "No user found with username #{username}"
    end

    @map.public_send("#{action}_editor", editor).save
    render json: { editors: editor_data }
  end

  def confirm_editor
    @map.confirm_editor(current_user)
    @map.save

    redirect_to oligrapher_path(@map)
  end

  # a POST request is how a user can "takeover" a locked map
  # A GET request does lock polling
  def lock
    begin
      check_private_access
      lock_service = ::OligrapherLockService.new(map: @map, current_user: current_user)
      lock_service.lock! if (is_owner && request.post?) || lock_service.user_can_lock?
      render json: lock_service.as_json.merge({ editors: editor_data })
    rescue Exceptions::PermissionError
      render json: ::OligrapherLockService.permission_error_json
    end
  end

  def release_lock
    check_private_access
    lock_service = ::OligrapherLockService.new(map: @map, current_user: current_user).release!
    render json: { lock_released: !lock_service.user_has_lock? }
  end

  def clone
    return head :unauthorized unless @map.cloneable? || is_owner

    check_ability :create_map

    map = @map.dup
    map.update!(
      is_featured: false,
      is_private: true,
      user_id: current_user.id,
      title: "Clone: #{map.title}"
    )

    render json: { redirect_url: oligrapher_path(map) }
  end

  def destroy
    @map.destroy
    respond_to do |format|
      format.json { render json: { redirect_url: new_oligrapher_path } }
      format.any { redirect_back(fallback_location: '/maps') }
    end
  end

  # Search API

  def find_nodes
    return head :bad_request if params[:q].blank?

    entities = EntitySearchService
                 .new(query: params[:q],
                      fields: %w[name aliases blurb],
                      num: params.fetch(:num, 10).to_i)
                 .search
                 .map { |e| Oligrapher::Node.from_entity(e) }

    render json: entities
  end

  def find_connections
    return head :bad_request if params[:entity_id].blank?

    query = EntityConnectionsQuery.new(Entity.find(params[:entity_id]))
    query.category_id = category_id_param
    query.page = 1
    query.per_page = params.fetch(:num, 10)
    query.excluded_ids = params[:excluded_ids]
    if %w[link_count current amount updated].include?(params[:order])
      query.order = params[:order].to_sym
    end

    render json: query.to_oligrapher_nodes
  end

  def get_edges
    return head :bad_request if params[:entity1_id].blank?
    return head :bad_request if params[:entity2_ids].blank?

    rel_ids = Link
                .where(entity1_id: params[:entity1_id].to_i)
                .where(entity2_id: params[:entity2_ids].split(','))
                .pluck(:relationship_id)

    edges = Relationship.find(rel_ids).map { |r| Oligrapher.rel_to_edge(r) }

    render json: edges
  end

  def get_interlocks
    return head :bad_request if params[:entity1_id].blank?
    return head :bad_request if params[:entity2_id].blank?
    return head :bad_request if params[:entity_ids].blank?

    num = params.fetch(:num, 10).to_i
    interlock_ids = Entity.interlock_ids(params[:entity1_id], params[:entity2_id])
    interlock_ids = (interlock_ids - params[:entity_ids].split(',').map(&:to_i)).take(num)

    if interlock_ids.count.positive?
      nodes = Entity
                .where(id: interlock_ids)
                .map { |e| Oligrapher::Node.from_entity(e) }
      rel_ids = Link
                  .where(entity1_id: [params[:entity1_id], params[:entity2_id]], entity2_id: interlock_ids)
                  .pluck(:relationship_id)
                  .uniq
      rels = Relationship.where(id: rel_ids)
      edges = rels.map { |r| Oligrapher.rel_to_edge(r) }

      render json: { nodes: nodes, edges: edges }
    else
      render json: { nodes: [], edges: [] }
    end
  end

  # New version of interlocks that can handle any number of entities
  def get_interlocks2
    return head :bad_request if params[:entity_ids].blank?
    num = params.fetch(:num, 10).to_i
    entity_ids = params[:entity_ids].split(',').map(&:to_i)
    interlock_ids = Entity.common_connections(entity_ids, amount: num)

    if interlock_ids.count.positive?
      nodes = Entity
                .where(id: interlock_ids)
                .map { |e| Oligrapher::Node.from_entity(e) }
      edges = Link
                .includes(:relationship)
                .where(entity1_id: entity_ids)
                .where(entity2_id: interlock_ids)
                .map(&:relationship)
                .uniq
                .map { |r| Oligrapher.rel_to_edge(r) }
      render json: { nodes: nodes, edges: edges }
    else
      render json: { nodes: [], edges: [] }
    end

  end

  # Admin

  def all
    # expires_in 2.minutes, public: false
    render json: { "data" =>  NetworkMap
                                .public_scope
                                .joins(:user)
                                .select(:id, :title, :description, :is_featured, :created_at, :updated_at, "users.username")
                                .order(id: :desc)
                                .all
                                .map { |m| m.attributes.merge!("url" => m.url) } }
  end

  def admin_destroy
    @map.soft_delete
    status = @map.is_deleted ? :ok : :bad_request
    render json: { id: @map.id, status: status.to_s.upcase }, status: status
  end

  private

  def new_oligrapher_params
    oligrapher_params.merge!(user_id: current_user.id)
  end

  def oligrapher_params
    params
      .require(:attributes)
      .permit(:title, :description, :is_private, :is_cloneable, :list_sources, :annotations_data, :settings, :oligrapher_commit)
      .merge(graph_data: params[:graph_data]&.permit!&.to_h)
  end

  def editor_data
    is_owner ? Oligrapher.editor_data(@map) : Oligrapher.confirmed_editor_data(@map)
  end

  def enforce_slug
    return if params[:secret]

    if @map.title.present? && !request.env['PATH_INFO'].match(Regexp.new(@map.to_param, true))
      redirect_to oligrapher_path(@map)
    end
  end

  def category_id_param
    if params[:category_id] && (1..12).cover?(params[:category_id].to_i)
      params[:category_id].to_i
    end
  end

  def set_cors_header
    headers['Access-Control-Allow-Origin'] = '*'
  end

  def set_map
    @map = NetworkMap.find(params[:id])
  end

  def is_owner
    current_user.present? && @map.user_id == current_user.id
  end

  def check_owner
    current_user.role.include? :create_map
    raise Exceptions::PermissionError unless is_owner
  end

  def check_private_access
    if @map.is_private && !can_view_if_private?
      unless params[:secret] && params[:secret] == @map.secret
        raise Exceptions::PermissionError
      end
    end
  end

  def can_view_if_private?
    @map.can_edit?(current_user) || @map.has_pending_editor?(current_user)
  end

  def map_not_found
    render 'errors/not_found', status: :not_found, layout: 'application'
  end
end
