class ImagesController < ApplicationController
  before_filter :auth
  before_action :set_image, only: [:crop, :crop_remote]

  def crop
    @type = @image.s3_exists?('large') ? 'large' : 'profile'
    @queue_count = entity_queue_count(:crop_images)
  end

  def crop_remote
    @queue_count = entity_queue_count(:crop_images)

    if params[:coords].present? and !params[:skip]
      coords = JSON.parse(params[:coords])
      @image.crop(coords['x'], coords['y'], coords['w'], coords['h'])
    end

    # permanently remove entity from queue
    if params[:skip]
      skip_queue_entity(:crop_images, @image.entity_id)
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
