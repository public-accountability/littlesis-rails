# frozen_string_literal: true

module Entities
  class ImagesController < ApplicationController
    include EntitiesHelper

    before_action :authenticate_user!, :current_user_can_edit?
    before_action :set_entity
    before_action :set_image, only: %i[update destroy]

    def index
    end

    def new
    end

    def create
      return head :bad_request unless image_params[:file] || image_params[:url]

      @image = new_image
      @image.assign_attributes(image_attributes)

      if @image.save
        redirect_to concretize_entity_images_path(@entity),
                    notice: 'Image was successfully created.'
      else
        render action: 'new_image', notice: 'Failed to add the image :('
      end
    end

    def update
      if @image.update!(image_params)
        redirect_to concretize_entity_images_path(@entity), notice: 'Image updated'
      end
    end

    def destroy
      check_ability :edit_destructively
      @image.soft_delete
      raise ActiveRecord::ActiveRecordError, 'Failed to delete image' unless @image.is_deleted

      flash[:notice] = 'Image deleted'
      redirect_to concretize_entity_images_path(@entity)
    end

    private

    def new_image
      if image_params[:file]
        Image.new_from_upload(image_params[:file])
      elsif image_params[:url]
        Image.new_from_url(image_params[:url])
      end
    end

    def set_image
      @image = Image.find(params.fetch(:id))
    end

    def entity_id
      params.select do |k|
        k =~ /entity_id|org_id|person_id/
      end.values.first
    end

    def set_entity
      @entity = Entity.unscoped.find(entity_id)
      raise Entity::EntityDeleted if @entity.is_deleted?
    end

    def image_params
      params.require(:image).permit(:file, :caption, :url, :is_free, :is_featured)
    end

    def image_attributes
      image_params.merge(entity: @entity).reject { |k| k == 'file' }
    end
  end
end
