class MapsController < ApplicationController
  before_action :set_map, except: [:index]
  before_filter :auth, only: [:capture]
  

  # GET /maps
  def index
    @maps = NetworkMap.order("updated_at DESC").page(params[:page]).per(20)
  end

  # GET /maps/1
  def show
    # render layout: "fullscreen"
  end

  def raw
    response.headers.delete('X-Frame-Options')
    render layout: "fullscreen"
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_map
    @map = NetworkMap.find(params[:id])
  end
end
