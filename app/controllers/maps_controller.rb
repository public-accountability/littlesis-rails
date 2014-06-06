class MapsController < ApplicationController
  before_action :set_map, except: [:index, :featured]
  before_filter :auth, only: [:all, :edit, :update]
  
  def index
    @maps = NetworkMap.order("updated_at DESC").page(params[:page]).per(20)
    @header = 'Network Maps'
  end

  def featured
    @maps = NetworkMap.featured.order("updated_at DESC").page(params[:page]).per(20)
    @header = 'Featured Maps'
    render 'index'
  end

  def show
  end

  def raw
    response.headers.delete('X-Frame-Options')
    render layout: "fullscreen"
  end

  def edit
    check_permission "admin"
  end

  def update
    check_permission "admin"    
    if @map.update(map_params)
      redirect_to map_path(@map), notice: 'Map was successfully updated.'
    else
      render action: 'edit'
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_map
    @map = NetworkMap.find(params[:id])
  end

  def map_params
    params.require(:map).permit(
      :is_featured, :title, :description, :bootsy_image_gallery_id
    )
  end
end
