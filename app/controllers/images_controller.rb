# frozen_string_literal: true

class ImagesController < ApplicationController
  before_action :authenticate_user!
  before_action -> { check_permission('admin') }, only: %i[approve_deletion deny_deletion]
  before_action :set_image_deletion_request, only: %i[approve_deletion deny_deletion]
  before_action :set_image, only: %i[request_deletion crop crop_remote]

  def request_deletion
    unless ImageDeletionRequest.exists?(image: @image)
      ImageDeletionRequest.create!(new_image_deletion_request_params)
    end
    redirect_back fallback_location: home_dashboard_path,
                  notice: 'Request is pending'
  end

  def approve_deletion
    @image_deletion_request.approved_by!(current_user)
    redirect_to home_dashboard_path
  end

  def deny_deletion
    @image_deletion_request.denied_by!(current_user)
    redirect_to home_dashboard_path
  end

  def crop
    @type = @image.s3_exists?('large') ? 'large' : 'profile'
  end

  def crop_remote
    if params[:coords].present?
      coords = JSON.parse(params[:coords])
      @image.crop(coords['x'], coords['y'], coords['w'], coords['h'])
    end
    redirect_to @image.entity.legacy_url
  end

  private

  def set_image
    @image = Image.find(params[:id])
  end

  def set_image_deletion_request
    @image_deletion_request = ImageDeletionRequest.find(params.require('image_deletion_request_id'))
  end

  def new_image_deletion_request_params
    { user: current_user,
      image: @image,
      justification: params.require('justification') }
  end
end
