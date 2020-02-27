# frozen_string_literal: true

# Oligrapher 3 API endpoints
#
# MapsController is used for Oligrapher 2 endpoints
# and the html pages for Oligrapher 2 and 3
class OligrapherController < ApplicationController
  include MapsHelper

  before_action :set_map, only: %i[update]
  before_action :authenticate_user!, except: %i[find_nodes]

  #  {
  #    graph_data: {...},
  #    attributes: { title, description, is_private, is_cloneable, list_sources }
  #  }
  def create
    map = NetworkMap.new(oligrapher_params)
    if map.validate
      map.save!
      render json: map
    else
      render json: map.errors, status: :bad_request
    end
  end

  def update
    check_owner

    if @map.update(oligrapher_params)
      head :ok
    else
      render json: @map.errors, status: :bad_request
    end
  end

  def example
    @oligrapher_version = '0f71f0d96fd443ceebc82c5981cd7aaac61584c5'
    render 'oligrapher/example', layout: 'oligrapher3'
  end

  def find_nodes
    return head :bad_request if params[:q].blank?

    entities = EntitySearchService
                 .new(query: params[:q],
                      fields: %w[name aliases blurb],
                      per_page: params.fetch(:num, 10).to_i)
                 .search
                 .map(&Oligrapher::Node.method(:from_entity))

    render json: entities
  end

  private

  def oligrapher_params
    params
      .require(:attributes)
      .permit(:title, :description, :is_private, :is_cloneable, :list_sources)
      .to_h
      .merge(graph_data: params[:graph_data]&.permit!&.to_h,
             oligrapher_version: 3,
             user_id: current_user.id)
  end
end

# Should we have some sort of GraphData validation?
#    OligrapherGraphData.new(params[:graph_data]).verify!
