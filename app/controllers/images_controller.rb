# frozen_string_literal: true

class ImagesController < ApplicationController
  ADMIN_ACTIONS = %i[deletion_request approve_deletion deny_deletion].freeze

  before_action :authenticate_user!
  before_action -> { check_permission('admin') }, only: ADMIN_ACTIONS
  before_action :set_image_deletion_request, only: ADMIN_ACTIONS
  before_action :set_image, only: %i[request_deletion crop]

  def request_deletion
    unless ImageDeletionRequest.exists?(image: @image)
      ImageDeletionRequest.create!(new_image_deletion_request_params)
    end
    redirect_back fallback_location: home_dashboard_path,
                  notice: 'Request is pending'
  end

  def deletion_request
  end

  def approve_deletion
    @image_deletion_request.approved_by!(current_user)
    redirect_to home_dashboard_path, notice: 'Image deletion request approved'
  end

  def deny_deletion
    @image_deletion_request.denied_by!(current_user)
    redirect_to home_dashboard_path, notice: 'Image deletion request denied'
  end

  def crop
    if request.post?
      new_image = Image.crop(@image, **crop_image_params)
      Image.replace old_image: @image, new_image: new_image
      render json: { "url": images_entity_path(@image.entity) }, status: :created
    else
      @image = ImageCropPresenter.new(@image)
    end
  end

  private

  def set_image
    @image = Image.find(params[:id])
  end

  def set_image_deletion_request
    @image_deletion_request = ImageDeletionRequest.find(params.require('image_deletion_request_id'))
  end

  def crop_image_params
    params
      .require(:crop)
      .permit(:type, :ratio, :x, :y, :w, :h)
      .to_h
      .symbolize_keys
  end

  def new_image_deletion_request_params
    { user: current_user,
      image: @image,
      entity_id: params.fetch('entity_id', nil),
      justification: params.require('justification') }
  end
end
