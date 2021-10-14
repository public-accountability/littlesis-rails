# frozen_string_literal: true

class FeaturedResourcesController < ApplicationController
  include EntitiesHelper
  before_action :authenticate_user!, :admins_only

  def create
    FeaturedResource.create!(params.require(:featured_resource).permit(:entity_id, :title, :url))
    redirect_to concretize_entity_path(
                  Entity.find(params.require(:featured_resource).require(:entity_id))
                )
  end

  def destroy
    fr = FeaturedResource.find(params[:id])
    entity = fr.entity
    fr.destroy!
    redirect_to concretize_entity_path(entity)
  end
end
