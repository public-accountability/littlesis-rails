# frozen_string_literal: true

class ImagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_image, only: [:crop, :crop_remote]

  def crop
    @type = @image.s3_exists?('large') ? 'large' : 'profile'
  end

  def crop_remote
    if params[:coords].present?
      coords = JSON.parse(params[:coords])
      @image.crop(coords['x'], coords['y'], coords['w'], coords['h'])
    end

    if @queue_count > 0
      next_entity_id = next_entity_in_queue(:crop_images)
      image_id = Image.where(entity_id: next_entity_id, is_featured: true).first
      redirect_to crop_image_path(id: image_id)
    else
      redirect_to @image.entity.legacy_url
    end
  end

  private

  def set_image
    @image = Image.find(params[:id])
  end
end
