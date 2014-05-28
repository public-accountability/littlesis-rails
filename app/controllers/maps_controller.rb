class MapsController < ApplicationController
  before_action :set_map
  
  # GET /maps
  def index
    @maps = NetworkMap.page(params[:page]).per(20)
  end

  # GET /maps/1
  def show
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_map
    @map = NetworkMap.find(params[:id])
  end
end
