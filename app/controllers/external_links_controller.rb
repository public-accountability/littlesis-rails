# frozen_string_literal: true

class ExternalLinksController < ApplicationController
  include EntitiesHelper

  before_action :authenticate_user!, :current_user_can_edit?

  def create
    el = ExternalLink.create!(external_link_params)
    redirect_to concretize_edit_entity_path(el.entity)
  end

  def update
    el = ExternalLink.find(params[:id])
    if external_link_params.fetch('link_id').blank?
      el.destroy!
    else
      el.update!(external_link_params)
    end
    redirect_to concretize_edit_entity_path(el.entity)
  end

  private

  def external_link_params
    params
      .require(:external_link)
      .permit(:link_type, :link_id, :entity_id)
      .to_h
  end
end
