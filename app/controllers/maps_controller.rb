# frozen_string_literal: true

class MapsController < ApplicationController
  include MapsHelper

  before_action :set_map,
                except: [:featured, :all, :new, :create, :search, :user, :find_nodes, :node_with_edges, :edges_with_nodes, :interlocks]
  before_action :authenticate_user!,
                except: [:featured, :all, :show, :raw, :search, :collection, :find_nodes, :node_with_edges, :share, :edges_with_nodes, :embedded, :embedded_v2, :interlocks]
  before_action :enforce_slug, only: [:show]
  before_action :admins_only, only: [:feature]

  before_action :set_oligrapher_version, only: %i[new show embedded_v2]

  before_action -> { check_permission 'editor' }, only: %i[create]

  protect_from_forgery except: [:create, :clone]

  # defaults for embedded oligrapher
  EMBEDDED_HEADER_PCT = 8
  EMBEDDED_ANNOTATION_PCT = 28

  OLIGRAPHER_VERSION_REGEX = /^[[:digit:]]\.[[:digit:]]\.[[:digit:]]$/

  def all
    if current_user.present?
      maps = NetworkMap.scope_for_user(current_user)
    else
      maps = NetworkMap.public_scope
    end
    @maps = maps
              .order('updated_at DESC')
              .page(params[:page].presence || 1)
              .per(20)
    @featured = false
    render :index
  end

  def featured
    @maps = NetworkMap
              .public_scope
              .featured
              .order("updated_at DESC, id DESC")
              .page(params[:page].presence || 1)
              .per(20)

    @featured = true
    render :index
  end

  def search
    @maps = NetworkMap
              .search(LsSearch.escape(params.fetch(:q, '')),
                      order: 'updated_at DESC, id DESC',
                      with: { is_private: false })
              .page(params[:page].presence || 1)
              .per(20)

    render :index
  end

  def user
    @maps_user = User.find_by!(username: params[:username])

    raise Exceptions::PermissionError unless current_user.admin? || current_user == @maps_user

    @maps = NetworkMap
              .where(user: @maps_user)
              .order(created_at: :desc)
              .page(params[:page].presence || 1)
              .per(20)

    render :index
  end

  def embedded_v2
    return redirect_to(embedded_oligrapher_path(@map)) if @map.version3?

    check_private_access
    @header_pct = embedded_params.fetch(:header_pct, EMBEDDED_HEADER_PCT)
    @annotation_pct = embedded_params.fetch(:annotation_pct, EMBEDDED_ANNOTATION_PCT)
    @start_index = embedded_params.fetch(:slide, 1).to_i - 1
    response.headers.delete('X-Frame-Options')
    render layout: 'embedded_oligrapher'
  end

  def embedded
    redirect_to(embedded_oligrapher_path(@map))
  end

  def map_json
    check_private_access
    attributes_to_return = ["id", "user_id", "created_at", "updated_at", "title", "description", "width", "height", "zoom", "is_private", "graph_data", "annotations_data", "annotations_count"]
    to_hash_if = lambda { |k,v| ["graph_data", "annotations_data"].include?(k) ?  ActiveSupport::JSON.decode(v) : v }

    render json: @map.attributes
             .select { |k,v| attributes_to_return.include?(k) }
             .map { |k,v| [k, to_hash_if.call(k,v) ]  }.to_h
  end

  def show
    redirect_to(oligrapher_path(@map))
  end

  # Main Legacy Oligrapher 2.0 show route
  # renders the 'story_map' template
  def show_legacy
    return redirect_to(oligrapher_path(@map)) if @map.version3?

    check_private_access

    @cacheable = true unless user_signed_in?
    @editable = false

    @links = [{ text: "embed", url: "#", id: "oligrapherEmbedLink" }]
    @links.push({ text: 'clone', url: clone_map_url(@map), method: 'POST' }) if @map.is_cloneable
    @links.push({ text: 'edit', url: edit_map_url(@map) }) if is_owner
    @links.push({ text: 'share link', url: share_map_url(id: @map.id, secret: @map.secret) }) if @map.is_private && is_owner
    @links.push(text: 'disclaimer', url: '#disclaimer') # see views/maps/_disclaimer_modal for the disclaimer modal

    render 'story_map', layout: 'oligrapher'
  end

  def raw
    # old map page for iframe embeds, forward to new embed page
    redirect_to embedded_map_path(@map)
  end

  def new
    redirect_to new_oligrapher_path
  end

  def new_legacy
    check_permission 'editor'

    if current_user.settings.oligrapher_beta
      return redirect_to new_oligrapher_path
    end

    @map = NetworkMap.new
    @map.title = 'Untitled Map'
    @map.user = current_user
    @editable = true
    render 'story_map', layout: 'oligrapher'
  end

  def create
    attributes = oligrapher_params.merge('user_id' => current_user.id,
                                         'oligrapher_version' => 2)

    map = NetworkMap.new(attributes)

    if map.save
      respond_to do |format|
        format.json { render json: map }
        format.html { redirect_to edit_map_path(map) }
      end
    else
      not_found
    end
  end

  def edit
    check_owner
    check_permission 'editor'

    @links = [
      { text: 'view', url: map_url(@map), target: '_blank' }
    ]

    @editable = true
    render 'story_map', layout: 'oligrapher'
  end

  def update
    check_owner

    if oligrapher_params.present?
      @map.update! oligrapher_params
      render json: { data: @map.attributes }
    else
      Rails.logger.warn "Missing oligrapher Parameters for map #{map.id}"
      render head :bad_request
    end
  end

  def destroy
    check_owner

    @map.destroy
    redirect_to maps_path
  end

  def clone
    return head :unauthorized unless @map.cloneable? || is_owner

    check_permission 'editor'

    map = @map.dup
    map.update!(is_featured: false,
                is_private: true,
                user_id: current_user.id,
                title: "Clone: #{map.title}")

    redirect_to edit_map_path(map)
  end

  ##
  # POST /maps/:id/feature
  # Two possible actions: { map: { feature_action: 'ADD' } | { feature_action: 'REMOVE' } }
  #
  # rubocop:disable Rails/SkipsModelValidations
  def feature
    # private maps cannot be featured
    return head :bad_request if @map.is_private

    case params.require(:map)[:feature_action]&.upcase
    when 'ADD'
      @map.update_columns(is_featured: true)
    when 'REMOVE'
      @map.update_columns(is_featured: false)
    else
      return head :bad_request
    end
    redirect_back fallback_location: all_maps_path
  end
  # rubocop:enable Rails/SkipsModelValidations

  # OLIRAPHER 2 SEARCH API

  def find_nodes
    return head :bad_request if params[:q].blank?

    fields = params[:desc] ? %w[name aliases blurb] : %w[name aliases]

    entities = EntitySearchService
                 .new(query: params[:q], fields: fields, per_page: params.fetch(:num, 10))
                 .search
                 .map { |e| Oligrapher.legacy_entity_to_node(e) }

    render json: entities
  end

  def node_with_edges
    entity_id = params[:node_id]
    entity_ids = params[:node_ids]
    node = Oligrapher.legacy_entity_to_node(Entity.find(entity_id))
    rel_ids = Link.where(entity1_id: entity_id, entity2_id: entity_ids).pluck(:relationship_id).uniq
    rels = Relationship.find(rel_ids)
    edges = rels.map { |r| Oligrapher.legacy_rel_to_edge(r) }
    render json: { node: node, edges: edges }
  end

  def edges_with_nodes
    entity = Entity.find(params[:node_id])
    entity_ids = params[:node_ids]
    relateds = entity.relateds
                 .where("link.category_id = #{params[:category_id]}")
                 .where.not(link: { entity2_id: entity_ids })
                 .limit(params[:num].to_i)
    nodes = relateds.map { |related| Oligrapher.legacy_entity_to_node(related) }
    all_ids = entity_ids.concat(relateds.map(&:id))
    rel_ids = Link.where(entity1_id: all_ids, entity2_id: relateds.map(&:id)).pluck(:relationship_id).uniq
    rels = Relationship.find(rel_ids)
    edges = rels.map { |r| Oligrapher.legacy_rel_to_edge(r) }
    render json: { nodes: nodes, edges: edges }
  end

  def interlocks
    num = params.fetch(:num, 10)
    interlock_ids = Entity.interlock_ids(params[:node1_id], params[:node2_id])
    interlock_ids = (interlock_ids - params[:node_ids].map(&:to_i)).take(num)

    if interlock_ids.count > 0
      entities = Entity.where(id: interlock_ids)
      nodes = entities.map { |entity| Oligrapher.legacy_entity_to_node(entity) }
      all_ids = interlock_ids.concat([params[:node1_id], params[:node2_id]]).concat(params[:node_ids])
      rel_ids = Link.where(entity1_id: all_ids, entity2_id: interlock_ids).pluck(:relationship_id).uniq
      rels = Relationship.where(id: rel_ids)
      edges = rels.map { |r| Oligrapher.legacy_rel_to_edge(r) }
      render json: { nodes: nodes, edges: edges }
    else
      render json: { nodes: [], edges: [] }
    end
  end

  private

  def enforce_slug
    return if params[:secret]

    is_json = request.path_info.match(/\.json$/)

    if !is_json && @map.title.present? && !request.env['PATH_INFO'].match(Regexp.new(@map.to_param, true))
      redirect_to map_path(@map)
    end
  end

  def oligrapher_params
    params
      .permit(:graph_data, :annotations_data, :annotations_count,
              :title, :is_private, :is_cloneable, :list_sources)
      .to_h
  end

  def embedded_params
    params.permit(:header_pct, :annotation_pct, :slide)
  end

  def set_oligrapher_version
    if params.key?(:oligrapher_version) && OLIGRAPHER_VERSION_REGEX.match?(params[:oligrapher_version])
      @oligrapher_version = params[:oligrapher_version]
    end
  end
end
