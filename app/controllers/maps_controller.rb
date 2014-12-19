class MapsController < ApplicationController
  before_action :set_map, except: [:index, :featured, :new, :create, :search, :splash]
  before_filter :auth, except: [:index, :featured, :show, :raw, :splash]
  before_filter :enforce_slug, only: [:show]

  protect_from_forgery except: :create

  def index
    maps = NetworkMap.order("updated_at DESC, id DESC")

    unless current_user.present? and current_user.has_legacy_permission('admin')
      if current_user.present?
        maps = maps.where("network_map.is_private = ? OR network_map.user_id = ?", false, current_user.sf_guard_user_id)
      else
        maps = maps.public_scope
      end
    end

    @maps = maps.page(params[:page]).per(20)
    @featured = false
  end

  def search
    order = "updated_at DESC, id DESC"
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

  def splash
    @maps = NetworkMap.featured.order("updated_at DESC, id DESC").page(params[:page]).per(50)
    @fcc_map = NetworkMap.find(101)
    @ferguson_map = NetworkMap.find(259)
  end

  def show
    if @map.is_private and !current_user.has_legacy_permission('admin') and (current_user.nil? or @map.user_id != current_user.sf_guard_user_id)
      raise Exceptions::PermissionError
    end
  end

  def raw
    response.headers.delete('X-Frame-Options')
    render layout: "fullscreen"
  end

  def new
    check_permission 'importer'
    @map = NetworkMap.new
  end

  def create
    check_permission 'importer'

    params = map_params
    params[:user_id] = current_user.sf_guard_user_id if params[:user_id].blank?
    params[:data] = JSON.dump({ entities: [], rels: [], texts: [] }) if params[:data].blank?
    params[:width] = Lilsis::Application.config.netmap_default_width if params[:width].blank?
    params[:height] = Lilsis::Application.config.netmap_default_width if params[:height].blank?
    params[:zoom] = '1' if params[:zoom].blank?

    @map = NetworkMap.create(params)

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
    check_permission 'importer'
  end

  def edit_meta
    check_owner
    check_permission 'importer'
  end

  def edit_fullscreen
    check_owner
    check_permission 'importer'
    response.headers.delete('X-Frame-Options')
    render layout: "fullscreen"
  end

  def update
    check_owner
    check_permission 'importer'

    data = params[:data]
    decoded = JSON.parse(data)

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

  def update_meta
    check_owner
    check_permission 'importer'

    if @map.update(map_params)
      redirect_to map_path(@map), notice: 'Map was successfully updated.'
    else
      render action: 'edit_meta'
    end
  end

  def destroy
    check_owner
    check_permission 'importer'

    @map.destroy
    redirect_to maps_path
  end

  def clone
    check_permission 'importer'

    map = @map.dup
    map.is_featured = false
    map.user_id = current_user.sf_guard_user_id
    map.save

    redirect_to edit_map_path(map)
  end

  private

  def enforce_slug
    if @map.title.present? and !request.env['PATH_INFO'].match(Regexp.new(@map.to_param, true))
      redirect_to map_path(@map)
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_map
    @map = NetworkMap.find(params[:id])
  end

  def map_params
    params.require(:map).permit(
      :is_featured, :is_private, :title, :description, :bootsy_image_gallery_id, :data,
       :height, :width, :user_id, :zoom
    )
  end

  def check_owner
    unless (current_user and current_user.has_legacy_permission('admin')) or @map.user_id == current_user.sf_guard_user_id
      raise Exceptions::PermissionError
    end
  end
end
