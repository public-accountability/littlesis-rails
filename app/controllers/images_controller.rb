class ImagesController < ApplicationController
  before_action :set_image, only: [:crop, :crop_remote]

  def crop
  end

  def crop_remote
    not_found unless params[:coords].present?
    coords = JSON.parse(params[:coords])
    @image.crop(coords['x'], coords['y'], coords['w'], coords['h'], 'large')
    redirect_to @image.entity.legacy_url
  end

  private

  def set_image
    @image = Image.find(params[:id])
  end
end
