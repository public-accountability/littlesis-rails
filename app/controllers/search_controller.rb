# frozen_string_literal: true

class SearchController < ApplicationController
  before_action :authenticate_user!, except: [:basic]
  before_action :set_page, only: [:basic]
  before_action :set_initial_search_values, only: [:basic]

  def basic
    query = params[:q]
    user_is_admin = current_user&.admin?

    if query.present?
      service = SearchService.new(query, page: @page, admin: user_is_admin)
      @entities = service.entities

      if @page == 1 # we only show entities if on page that is not the first
        @lists = service.lists
        @maps = service.maps
        @tags = service.tags if user_is_admin
      end
    end

    @no_results = (@lists.count + @entities.count + @maps.count + @tags.count).zero?

    respond_to do |format|
      format.html { render 'basic' }

      format.json do
        entities = @entities.map { |e| Entity::Search.entity_with_summary(e) }
        render json: { entities: entities }
      end
    end
  end

  # /search/entity?q=ENTITY_NAME
  def entity_search
    return head :bad_request unless params[:q].present?

    options = { with: { is_deleted: false } }
    options[:with][:primary_ext] = params[:ext].capitalize if params[:ext]
    options[:num] = params[:num].to_i if params[:num]

    search_results = Entity::Search.search(params[:q], options)

    if params[:no_summary]
      render json: search_results.map { |e| Entity::Search.entity_no_summary(e) }
    else
      render json: search_results.map { |e| Entity::Search.entity_with_summary(e) }
    end
  end

  private

  def set_initial_search_values
    @entities = []
    @groups = []
    @lists = []
    @maps = []
    @tags = []
  end

  def set_page
    @page = params.fetch(:page, 1).to_i
  end
end
