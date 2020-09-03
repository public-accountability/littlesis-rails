# frozen_string_literal: true

class ImagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_image, only: %i[crop update]

  def crop
    if request.post?
      new_image = Image.crop(@image, **crop_image_params)
      Image.replace old_image: @image, new_image: new_image
      render json: { "url": images_entity_path(@image.entity) }, status: :created
    else
      @image = ImageCropPresenter.new(@image)
    end
  end

  # POST /images/:id/update
  # This route varies from rails convention by adding /update
  def update
    @image.update(image_update_params)
    redirect_to images_entity_path(@image.entity)
  end

  private

  def set_image
    @image = Image.find(params[:id])
  end

  def crop_image_params
    params
      .require(:crop)
      .permit(:type, :ratio, :x, :y, :w, :h)
      .to_h
      .symbolize_keys
  end

  def image_update_params
    params.require(:image).permit(:caption).to_h
  end
end
