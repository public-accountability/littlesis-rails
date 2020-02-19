# frozen_string_literal: true

class OligrapherController < ApplicationController
  before_action :authenticate_user!, only: [:example]

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
