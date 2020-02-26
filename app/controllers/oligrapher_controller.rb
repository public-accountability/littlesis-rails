# frozen_string_literal: true

# Oligrapher 3 API endpoints
# MapsController is used for Oligrapher 2 endpoints and the
# html pages for Oligrapher 2 and 3
class OligrapherController < ApplicationController
  before_action :authenticate_user!, except: [:find_nodes]

  def create
    NetworkMap.create!(version: 3,
                       user_id: current_user.id,
                       graph_data: params.require(:graph_data))
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
end
