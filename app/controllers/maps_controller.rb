class MapsController < ApplicationController
  before_action :set_map, except: [:index, :featured]
  before_filter :auth, only: [:all, :edit, :edit_meta, :update, :update_meta]
  before_filter :enforce_slug, only: [:show]

  def index
    maps = NetworkMap.order("updated_at DESC")
    maps = maps.public_scope unless current_user.has_legacy_permission('admin')
    @maps = maps.page(params[:page]).per(20)
    @header = 'Network Maps'
  end

  def featured
    @maps = NetworkMap.featured.order("updated_at DESC").page(params[:page]).per(20)
    @header = 'Featured Maps'
    render 'index'
  end

  def show
    if @map.is_private and (current_user.nil? or @map.user_id != current_user.sf_guard_user_id)
      raise Exceptions::PermissionError
    end
  end

  def raw
    response.headers.delete('X-Frame-Options')
    render layout: "fullscreen"
  end

  def edit
    check_owner
  end

  def edit_meta
    check_owner
  end

  def update
    check_owner

    data = params[:data]
    decoded = JSON.parse(data)

    @map.width = params[:width] if params[:width].present?
    @map.height = params[:height] if params[:height].present?
    @map.zoom = params[:zoom] if params[:zoom].present?
    @map.data = data
    @map.entity_ids = decoded['entities'].map { |e| e['id'] }.join(',')
    @map.rel_ids = decoded['rels'].map { |e| e['id'] }.join(',')
    binding.pry
    @map.save

    # NEED CACHE CLEAR HERE

    render json: @map
  end

  def update_meta
    check_permission "admin"    
    if @map.update(map_params)
      redirect_to map_path(@map), notice: 'Map was successfully updated.'
    else
      render action: 'edit'
    end
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
      :is_featured, :is_private, :title, :description, :bootsy_image_gallery_id
    )
  end

  def check_owner
    unless current_user.has_legacy_permission('admin') or @map.user_id == current_user.sf_guard_user_id
      raise Exceptions::PermissionError
    end
  end
end
