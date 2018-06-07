# frozen_string_literal: true

class ExternalLinksController < ApplicationController
  before_action :authenticate_user!

  def create
    el = ExternalLink.create!(external_link_params)
    redirect_to edit_entity_path(el.entity)
  end

  def update
    el = ExternalLink.find(params[:id])
    el.update!(external_link_params)
    redirect_to edit_entity_path(el.entity)
  end

  def destroy
    el = ExternalLink.find(params[:id])
    el.update!(external_link_params)
    redirect_to edit_entity_path(el.entity)
  end

  private

  def external_link_params
    params
      .require(:external_link)
      .permit(:link_type, :link_id, :entity_id)
  end
end
