class MapsController < ApplicationController
  before_action :set_map, except: [:index, :featured, :new, :create, :search, :splash, :create_annotation]
  before_filter :auth, except: [:index, :featured, :show, :raw, :splash, :search]
  before_filter :enforce_slug, only: [:show]

  # protect_from_forgery with: :null_session, only: Proc.new { |c| c.request.format.json? }

  protect_from_forgery except: [:create, :create_annotation, :update_annotation]

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

    @shale_map = NetworkMap.find(152)
    @hadley_map = NetworkMap.find(238)
    @moma_map = NetworkMap.find(282)

    @lawmaking_map = NetworkMap.find(542)
    @uc_map = NetworkMap.find(228)
    @goldwyn_map = NetworkMap.find(431)

    @mugabe_map = NetworkMap.find(266)
    @goldman_map = NetworkMap.find(157)
    @berman_map = NetworkMap.find(137)
  end

  def show
    if @map.is_private and (!current_user or !current_user.has_legacy_permission('admin')) and (current_user.nil? or @map.user_id != current_user.sf_guard_user_id)
      raise Exceptions::PermissionError
    end

    respond_to do |format|
      format.html
      format.json {
        render json: { map: map.to_clean_hash }
      }
    end
  end

  def raw
    response.headers.delete('X-Frame-Options')
    render layout: "fullscreen"
  end

  def new
    check_permission 'editor'
    @map = NetworkMap.new
    @map.title = 'Untitled Map'
  end

  def create
    check_permission 'editor'

    params = map_params
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
  end

  def edit_meta
    check_owner
    check_permission 'editor'
  end

  def edit_fullscreen
    check_owner
    check_permission 'editor'
    response.headers.delete('X-Frame-Options')
    render layout: "fullscreen"
  end

  def update
    check_owner
    check_permission 'editor'

    params = map_params
    data = params[:data]
    decoded = JSON.parse(data)

    @map.title = params[:title] if params[:title].present?
    @map.description = params[:description] if params[:title].present?
    @map.is_featured = params[:is_featured] if params[:is_featured].present?
    @map.is_private = params[:is_private] if params[:is_private].present?
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
    check_permission 'editor'

    if @map.update(map_params)
      redirect_to map_path(@map), notice: 'Map was successfully updated.'
    else
      render action: 'edit_meta'
    end
  end

  def destroy
    check_owner
    check_permission 'editor'

    @map.destroy
    redirect_to maps_path
  end

  def clone
    check_permission 'editor'

    map = @map.dup
    map.is_featured = false
    map.user_id = current_user.sf_guard_user_id
    map.save

    redirect_to edit_map_path(map)
  end

  def annotations
    check_owner
  end

  def new_annotation
    check_owner
    @annotation = MapAnnotation.new(map: @map)
  end

  def create_annotation
    check_owner
    @annotation = MapAnnotation.new(annotation_params)

    if @annotation.save
      redirect_to annotations_map_path(NetworkMap.find(@annotation.map_id)), notice: 'Annotation was successfully created.'
    else
      render :new_annotation
    end
  end

  def edit_annotation
    check_owner
    @annotation = MapAnnotation.find(params[:annotation_id])
  end

  def update_annotation
    check_owner
    @annotation = MapAnnotation.find(annotation_params[:id])

    if @annotation.update(annotation_params)
      redirect_to annotations_map_path(@annotation.map), notice: 'Annotation was successfully updated.'
    else
      render :edit_annotation
    end
  end

  def reorder_annotations
    check_owner
    annotation_ids = params[:annotation_ids].split(',')
    annotation_ids.each_with_index do |id, index|
      MapAnnotation.find(id).update(order: index + 1)
    end

    render json: { success: { id: @map.id, annotation_ids: annotation_ids } }
  end

  def destroy_annotation
    check_owner
    annotation = MapAnnotation.find(params[:annotation_id])
    annotation.destroy
    redirect_to annotations_map_path(@map), notice: 'Annotation was successfully deleted.'
  end

  def collection
    respond_to do |format|
      format.json {
        ary = @map.annotations.present? ? @map.annotations.sort_by(&:order).map(&:to_map_data) : [@map.to_clean_hash]
        collection = { 
          id: @map.id,
          title: @map.title,
          maps: ary
        }

        render json: { collection: collection }
      }
    end
  end

  private

  def enforce_slug
    is_json = request.path_info.match(/\.json$/)

    if !is_json and @map.title.present? and !request.env['PATH_INFO'].match(Regexp.new(@map.to_param, true))
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

  def annotation_params
    params.require(:annotation).permit(
      :id, :map_id, :title, :description, :highlighted_entity_ids, :highlighted_rel_ids, :highlighted_text_ids
    )
  end

  def check_owner
    unless current_user and (current_user.has_legacy_permission('admin') or @map.user_id == current_user.sf_guard_user_id)
      raise Exceptions::PermissionError
    end
  end
end
