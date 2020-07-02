# frozen_string_literal: true

# Oligrapher 3 API endpoints
#
# MapsController is used for Oligrapher 2 endpoints
# and the html pages for Oligrapher 2 and 3
class OligrapherController < ApplicationController
  include MapsHelper

  skip_before_action :verify_authenticity_token if Rails.env.development?

  before_action :authenticate_user!, except: %i[show find_nodes find_connections get_edges get_interlocks embedded]
  before_action :set_map, only: %i[update get_editors editors confirm_editor show lock clone destroy embedded]
  before_action :enforce_slug, only: %i[show]
  before_action :check_owner, only: %i[editors destroy]
  before_action :check_editor, only: %i[update]
  before_action :set_oligrapher_version

  before_action :admins_only if Rails.env.production?

  # Crud actions

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
      render json:@map.errors, status: :bad_request
    end
  end

  def new
    @map = NetworkMap.new(oligrapher_version: 3, title: 'Untitled Map', user: current_user)
    @configuration = Oligrapher.configuration(map: @map, current_user: current_user)
    render 'oligrapher/new', layout: 'oligrapher3'
  end

  def get_editors
    render json: editor_data
  end

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
    check_private_access
    raise Exceptions::PermissionError unless @map.can_edit?(current_user)

    lock_service = ::OligrapherLockService.new(map: @map, current_user: current_user)
    lock_service.lock! if request.post? || lock_service.user_can_lock?
    render json: lock_service.as_json
  end

  def clone
    return head :unauthorized unless @map.cloneable? || is_owner

    check_permission 'editor'

    map = @map.dup
    map.update!(
      oligrapher_version: 3,
      is_featured: false,
      is_private: true,
      user_id: current_user.id,
      title: "Clone: #{map.title}"
    )

    render json: { redirect_url: oligrapher_path(map) }
  end

  def destroy
    @map.destroy
    render json: { redirect_url: new_oligrapher_path }
  end

  # Pages

  def show
    check_private_access
    @is_pending_editor = (current_user and @map.has_pending_editor?(current_user))
    @configuration = Oligrapher.configuration(map: @map, current_user: current_user)
    render 'oligrapher/oligrapher', layout: 'oligrapher3'
  end

  def embedded
    check_private_access
    @configuration = Oligrapher.configuration(map: @map, current_user: current_user, embed: true)
    render layout: 'embedded_oligrapher'
  end

  def example
    render 'oligrapher/example', layout: 'oligrapher3'
  end

  # Search Api
  def find_nodes
    return head :bad_request if params[:q].blank?

    entities = EntitySearchService
                 .new(query: params[:q],
                      fields: %w[name aliases blurb],
                      per_page: params.fetch(:num, 10).to_i)
                 .search
                 .map(&Oligrapher::Node.method(:from_entity))

    render json: entities
  end

  def find_connections
    return head :bad_request if params[:entity_id].blank?

    entity = Entity.find(params[:entity_id])
    nodes = {}

    EntityConnectionsQuery
      .new(entity)
      .category(params[:category_id])
      .page(1)
      .per(params.fetch(:num, 10))
      .run
      .each { |e|
        nodes[e.id] = Oligrapher::Node.from_entity(e) unless nodes[e.id]
        nodes[e.id][:edges] = [] unless nodes[e.id][:edges].present?
        nodes[e.id][:edges].push(Oligrapher.rel_to_edge(Relationship.find(e.relationship_id)))
      }

    render json: nodes.values
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
    oligrapher_params.merge!(oligrapher_version: 3, user_id: current_user.id)
  end

  def oligrapher_params
    params
      .require(:attributes)
      .permit(:title, :description, :is_private, :is_cloneable, :list_sources, :annotations_data, :settings)
      .merge(graph_data: params[:graph_data]&.permit!&.to_h)
      .merge(oligrapher_version: 3)
  end

  def set_oligrapher_version
    @oligrapher_version = Oligrapher::VERSION
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
end

# Should we have some sort of GraphData validation?
#    OligrapherGraphData.new(params[:graph_data]).verify!
