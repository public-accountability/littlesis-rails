# frozen_string_literal: true

# Oligrapher 3 API endpoints
#
# See MapsController for Oligrapher 2 endpoints
class OligrapherController < ApplicationController
  include MapsHelper

  skip_before_action :verify_authenticity_token if Rails.env.development?

  AUTHENITICATED_ACTIONS = %i[new create update editors confirm_editor lock release_lock clone destroy].freeze

  before_action :authenticate_user!, only: AUTHENITICATED_ACTIONS
  before_action :block_restricted_user_access, only: AUTHENITICATED_ACTIONS
  before_action :set_map, only: %i[update editors confirm_editor show lock release_lock clone destroy embedded screenshot]
  before_action :enforce_slug, only: %i[show]
  before_action :check_owner, only: %i[editors destroy]
  before_action :check_editor, only: %i[update]

  rescue_from ActiveRecord::RecordNotFound, with: :map_not_found
  rescue_from Exceptions::PermissionError, with: :map_not_found
  rescue_from Exceptions::RestrictedUserError, with: -> { head :forbidden }

  # Explore Maps Page
  def index
    respond_to do |format|
      format.html
      format.json do
        expires_in 6.hours, :public => true
        render :json => NetworkMap.index_maps
      end
    end
  end

  def search
  end

  def perform_search
    @query = params[:query]&.strip

    if @query.present?
      current_user_id = current_user.id if user_signed_in? && params[:personal_search]
      @search_results = OligrapherSearchService.run(@query, user_id: current_user_id)
    end

    render partial: 'search_results'
  end

  def grid
    @grid = Oligrapher::Grid.new(params.fetch('oligrapher_grid', {}))
    @grid.scope { |scope| scope.page(params[:page] || 1).per(25) }
  end

  def show
    check_private_access
    @is_pending_editor = (current_user && @map.has_pending_editor?(current_user))
    @configuration = Oligrapher.configuration(map: @map, current_user: current_user)
    render 'oligrapher/oligrapher', layout: 'oligrapher3'
  end

  def embedded
    check_private_access
    @configuration = Oligrapher.configuration(map: @map, current_user: current_user, embed: true)
    response.headers.delete('X-Frame-Options')
    render layout: 'embedded_oligrapher'
  end

  def new
    @map = NetworkMap.new(title: 'Untitled Map', user: current_user)
    @configuration = Oligrapher.configuration(map: @map, current_user: current_user)
    render 'oligrapher/new', layout: 'oligrapher3'
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
    @map.assign_attributes(oligrapher_params)

    if @map.validate
      @map.save!
      @configuration = Oligrapher.configuration(map: @map, current_user: current_user)
      render json: @configuration
    else
      render json: @map.errors, status: :bad_request
    end
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

    check_permission 'editor'

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
                 .map(&Oligrapher::Node.method(:from_entity))

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

    edges = Relationship.find(rel_ids).map(&Oligrapher.method(:rel_to_edge))

    render json: edges
  end

  def get_interlocks
    return head :bad_request if params[:entity1_id].blank?
    return head :bad_request if params[:entity2_id].blank?
    return head :bad_request if params[:entity_ids].blank?

    num = params.fetch(:num, 10).to_i
    interlock_ids = Entity.interlock_ids(params[:entity1_id], params[:entity2_id])
    interlock_ids = (interlock_ids - params[:entity_ids].split(',').map(&:to_i)).take(num)

    if interlock_ids.count > 0
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

  private

  def new_oligrapher_params
    oligrapher_params.merge!(user_id: current_user.id)
  end

  def oligrapher_params
    params
      .require(:attributes)
      .permit(:title, :description, :is_private, :is_cloneable, :list_sources, :annotations_data, :settings)
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
end

# Should we have some sort of GraphData validation?
#    OligrapherGraphData.new(params[:graph_data]).verify!
