# frozen_string_literal: true

module DeletionRequests
  class ImagesController < DeletionRequests::BaseController
    before_action :set_image, only: :create

    def show
    end

    def create
      unless ImageDeletionRequest.exists?(image: @image)
        ImageDeletionRequest.create!(request_params)
      end

      if turbo_frame_request?
        render partial: 'request_pending', locals: { image: @image }
      else
        redirect_back fallback_location: home_dashboard_path, notice: 'Request is pending'
      end
    end

    private

    def set_image
      @image = Image.find(params[:image_id])
    end

    def set_deletion_request
      @deletion_request = ImageDeletionRequest.find(params.require('id'))
    end

    def request_params
      {
        user: current_user,
        image: @image,
        entity_id: params.fetch('entity_id', nil),
        justification: params.require('justification')
      }
    end
  end
end
