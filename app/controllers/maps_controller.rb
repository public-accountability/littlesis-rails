class MapsController < ApplicationController
  include NetworkMapsHelper

  before_action :set_map, except: [:index, :featured, :new, :create, :search, :find_nodes, :node_with_edges, :edges_with_nodes, :interlocks]
  before_filter :authenticate_user!, except: [:index, :featured, :show, :raw, :search, :collection, :find_nodes, :node_with_edges, :share, :edges_with_nodes, :embedded, :embedded_v2, :interlocks]
  before_filter :enforce_slug, only: [:show]

  # protect_from_forgery with: :null_session, only: Proc.new { |c| c.request.format.json? }

  protect_from_forgery except: [:create, :clone]

  # defaults for embedded oligrapher
  EMBEDDED_HEADER_PCT = 8
  EMBEDDED_ANNOTATION_PCT = 28

  def index
    maps = NetworkMap.order('created_at DESC, id DESC')

    unless current_user.present? and current_user.has_legacy_permission('admin')
      if current_user.present?
        maps = maps.where('network_map.is_private = ? OR network_map.user_id = ?', false, current_user.sf_guard_user_id)
      else
        maps = maps.public_scope
      end
    end

    @maps = maps.page(params[:page]).per(20)
    @featured = false
  end

  def search
    order = 'updated_at DESC, id DESC'
    if user_signed_in?
      if current_user.has_legacy_permission('admin')
        @maps = NetworkMap.search(
          Riddle::Query.escape(params.fetch(:q, '')),
          order: order
        ).page(params[:page]).per(20)
      else
        @maps = NetworkMap.search(
          Riddle::Query.escape(params.fetch(:q, '')),
          order: order,
          with: { visible_to_user_ids: [0, current_user.sf_guard_user_id] }
        ).page(params[:page]).per(20)
      end
    else
      @maps = NetworkMap.search(
        Riddle::Query.escape(params.fetch(:q, '')),
        order: order,
        with: { visible_to_user_ids: [0] }
      ).page(params[:page]).per(20)
    end
  end

  def featured
    @maps = NetworkMap.featured.order("updated_at DESC, id DESC").page(params[:page]).per(20)
    @featured = true
    render 'index'
  end

  def embedded_v2
    @header_pct = embedded_params.fetch(:header_pct, EMBEDDED_HEADER_PCT)
    @annotation_pct = embedded_params.fetch(:annotation_pct, EMBEDDED_ANNOTATION_PCT)
    response.headers.delete('X-Frame-Options')
    render layout: 'embedded_oligrapher'
  end

  def embedded_v2_dev
    @dev_version = true

    @header_pct = embedded_params.fetch(:header_pct, EMBEDDED_HEADER_PCT)
    @annotation_pct = embedded_params.fetch(:annotation_pct, EMBEDDED_ANNOTATION_PCT)
    response.headers.delete('X-Frame-Options')
    render 'embedded_v2', layout: 'embedded_oligrapher'
  end

  def embedded
    response.headers.delete('X-Frame-Options')
    render layout: 'fullscreen'
  end

  def map_json
    if @map.is_private and !is_owner
      raise Exceptions::PermissionError
    end
    attributes_to_return = ["id", "user_id", "created_at", "updated_at", "title", "description", "width", "height", "zoom", "is_private", "graph_data", "annotations_data", "annotations_count"]
    to_hash_if = lambda { |k,v| ["graph_data", "annotations_data"].include?(k) ?  ActiveSupport::JSON.decode(v) : v }

    render json: @map.attributes
            .select { |k,v| attributes_to_return.include?(k) }
            .map { |k,v| [k, to_hash_if.call(k,v) ]  }.to_h
  end

  def show
    if @map.is_private and !is_owner
      unless params[:secret] and params[:secret] == @map.secret
        raise Exceptions::PermissionError
      end
    end

    @cacheable = true unless user_signed_in?

    respond_to do |format|
      format.html {
        @editable = false
        @links = [
          { text: "embed", url: "#", id: "oligrapherEmbedLink" }
        ]
        @links.push({ text: 'clone', url: clone_map_url(@map), method: 'POST' }) if @map.is_cloneable
        @links.push({ text: 'edit', url: edit_map_url(@map) }) if is_owner
        @links.push({ text: 'share link', url: share_map_url(id: @map.id, secret: @map.secret) }) if @map.is_private and is_owner

        if params[:embed]
          response.headers.delete('X-Frame-Options')
          render action: 'story_map', layout: 'fullscreen'
        else
          render 'story_map'
        end
      }
      format.json {
        render json: { map: @map.to_clean_hash }
      }
    end
  end

  def dev
    check_permission 'admin'

    if @map.is_private and !is_owner
      unless params[:secret] and params[:secret] == @map.secret
        raise Exceptions::PermissionError
      end
    end

    @editable = false
    @links = [
      { text: 'embed', url: '#', id: 'oligrapherEmbedLink' },
      { text: 'clone', url: clone_map_url(@map), method: 'POST' }
    ]
    @links.push({ text: 'edit', url: edit_map_url(@map) }) if is_owner
    @links.push({ text: 'share link', url: share_map_url(id: @map.id, secret: @map.secret) }) if @map.is_private and is_owner

    @dev_version = true
    render 'story_map'
  end

  def raw
    # old map page for iframe embeds, forward to new embed page
    redirect_to embedded_map_path(@map)
  end

  def new
    check_permission 'editor'
    @map = NetworkMap.new
    @map.title = 'Untitled Map'
    @map.user = current_user
    @editable = true
    render 'story_map'
  end

  def create
    check_permission 'editor'

    params = oligrapher_params
    params[:user_id] = current_user.sf_guard_user_id if params[:user_id].blank?
    @map = NetworkMap.new(params)

    if @map.save
      respond_to do |format|
        format.json { render json: @map }
        format.html { redirect_to edit_map_path(@map) }
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
    render 'story_map'
  end

  def dev_edit
    check_owner
    check_permission 'admin'
    @links = [{ text: 'view', url: map_url(@map), target: '_blank' }]
    @editable = true
    @dev_version = true
    render 'story_map'
  end

  def update
    check_owner
    check_permission 'editor'

    if oligrapher_params.present?
      @map.update(oligrapher_params)
      render json: { data: @map.attributes }
      # render json: { data: hash }
    else
      params = map_params
      data = params[:data]
      decoded = JSON.parse(data)

      @map.title = params[:title] if params[:title].present?
      @map.description = params[:description] if params[:title].present?
      @map.is_featured = params[:is_featured] if params[:is_featured].present?
      @map.is_private = params[:is_private] if params[:is_private].present?
      @map.is_cloneable = params[:is_cloneable] if params[:is_cloneable].present?
      @map.width = params[:width] if params[:width].present?
      @map.height = params[:height] if params[:height].present?
      @map.zoom = params[:zoom] if params[:zoom].present?
      @map.data = data
      @map.entity_ids = decoded['entities'].map { |e| e['id'] }.join(',')
      @map.rel_ids = decoded['rels'].map { |e| e['id'] }.join(',')
      @map.save

      # NEED CACHE CLEAR HERE

      render json: @map
    end
  end

  def destroy
    check_owner
    check_permission 'editor'

    @map.destroy
    redirect_to maps_path
  end

  def clone
    return head :unauthorized unless @map.is_cloneable
    check_permission 'editor'

    map = @map.dup
    map.is_featured = false
    map.user_id = current_user.sf_guard_user_id
    map.save

    redirect_to edit_map_path(map)
  end

  # OLIRAPHER 2 SEARCH API

  def find_nodes
    q = params[:q]
    num = params.fetch(:num, 10)
    fields = params[:desc] ? 'name,aliases,blurb' : 'name,aliases'
    entities = Entity.search(
      "@(#{fields}) #{q}",
      per_page: num,
      match_mode: :extended,
      with: { is_deleted: false },
      select: "*, weight() * (link_count + 1) AS link_weight",
      order: 'link_weight DESC'
    )
    data = entities.map { |e| Oligrapher.entity_to_node(e) }
    render json: data
  end

  def node_with_edges
    entity_id = params[:node_id]
    entity_ids = params[:node_ids]
    node = Oligrapher.entity_to_node(Entity.find(entity_id))
    rel_ids = Link.where(entity1_id: entity_id, entity2_id: entity_ids).pluck(:relationship_id).uniq
    rels = Relationship.find(rel_ids)
    edges = rels.map { |r| Oligrapher.rel_to_edge(r) }
    render json: { node: node, edges: edges }
  end

  def edges_with_nodes
    entity = Entity.find(params[:node_id])
    entity_ids = params[:node_ids]
    relateds = entity.relateds
      .where("link.category_id = #{params[:category_id]}")
      .where.not(link: { entity2_id: entity_ids })
      .limit(params[:num].to_i)
    nodes = relateds.map { |related| Oligrapher.entity_to_node(related) }
    all_ids = entity_ids.concat(relateds.map(&:id))
    rel_ids = Link.where(entity1_id: all_ids, entity2_id: relateds.map(&:id)).pluck(:relationship_id).uniq
    rels = Relationship.find(rel_ids)
    edges = rels.map { |r| Oligrapher.rel_to_edge(r) }
    render json: { nodes: nodes, edges: edges }
  end

  def interlocks
    num = params.fetch(:num, 10)
    interlock_ids = Entity.interlock_ids(params[:node1_id], params[:node2_id])
    interlock_ids = (interlock_ids - params[:node_ids].map(&:to_i)).take(num)

    if interlock_ids.count > 0
      entities = Entity.where(id: interlock_ids)
      nodes = entities.map { |entity| Oligrapher.entity_to_node(entity) }
      all_ids = interlock_ids.concat([params[:node1_id], params[:node2_id]]).concat(params[:node_ids])
      rel_ids = Link.where(entity1_id: all_ids, entity2_id: interlock_ids).pluck(:relationship_id).uniq
      rels = Relationship.where(id: rel_ids)
      edges = rels.map { |r| Oligrapher.rel_to_edge(r) }
      render json: { nodes: nodes, edges: edges }
    else
      render json: { nodes: [], edges: [] }
    end
  end

  private

  def enforce_slug
    return if params[:secret]

    is_json = request.path_info.match(/\.json$/)

    if !is_json and @map.title.present? and !request.env['PATH_INFO'].match(Regexp.new(@map.to_param, true))
      redirect_to smart_map_path(@map)
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_map
    if user_signed_in?
      @map = NetworkMap.find(params[:id])
    else
      @map = Rails.cache.fetch("maps_controller/network_map/#{params[:id]}", expires_in: 5.minutes)  { NetworkMap.find(params[:id]) } 
    end
  end

  def map_params
    params.require(:map).permit(
      :is_featured, :is_private, :title, :description, :data,
       :height, :width, :user_id, :zoom
    )
  end

  def oligrapher_params
    params.permit(:graph_data, :annotations_data, :annotations_count, :title, :is_private, :is_featured, :is_cloneable, :list_sources)
  end

  def embedded_params
   params.permit(:header_pct, :annotation_pct)
  end

  def is_owner
    current_user and (current_user.has_legacy_permission('admin') or @map.user_id == current_user.sf_guard_user_id)
  end

  def check_owner
    unless is_owner
      raise Exceptions::PermissionError
    end
  end
end
