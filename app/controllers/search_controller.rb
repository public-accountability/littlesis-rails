# frozen_string_literal: true

class SearchController < ApplicationController
  before_action :set_initial_search_values, only: [:basic]
  before_action :set_page, only: [:basic]
  before_action :set_and_validate_tag_filter, only: [:basic]

  def basic
    query = params[:q].presence
    user_is_admin = current_user&.admin?

    if query.present?
      service = SearchService.new(query, page: @page, admin: user_is_admin, tag_filter: @tag_filter&.name)
      @entities = service.entities

      # On the first page we show results for all categories: only entities can be paginated.
      # Right now, only searching for entiteis can be filtered by tag, so
      # if there is a tag filter, we can only display the entity results
      if @page == 1 && !@tag_filter
        @lists = service.lists
        @maps = service.maps
        @tags = service.tags if user_is_admin
      end
    end

    @no_results = (@lists.count + @entities.count + @maps.count + @tags.count).zero?

    respond_to do |format|
      format.html { render 'basic' }

      format.json do
        entities = @entities.map { |e| e.to_hash(image_url: true) }
        render json: { entities: entities }
      end
    end
  end

  # /search/entity
  # require param: q
  # optional params:
  #  - ext : "org" or "person"
  #  - num : Int
  #  - tags | String|Array (if string, can be comma separated)
  #  - exclude_list | id
  #  - include_image_url : boolean
  #  - include_parent : boolean
  def entity_search
    return head :bad_request if params[:q].blank?

    service = EntitySearchService.new(query: params[:q], **entity_search_options)
    results = service.to_array(image_url: params[:include_image_url], parent: params[:include_parent])
    render json: results
  end

  private

  def entity_search_options
    {}.tap do |options|
      options[:with] = { primary_ext: params[:ext].capitalize } if params[:ext]
      options[:num] = params[:num].to_i if params[:num]
      options[:tags] = params[:tags] if params[:tags]
      if params[:exclude_list] && /\A[0-9]+\Z/.match?(params[:exclude_list])
        options[:exclude_list] = params[:exclude_list].to_i
      end
    end
  end

  def set_initial_search_values
    @entities = []
    @groups = []
    @lists = []
    @maps = []
    @tags = []
    @tag_filter = nil
  end

  def set_page
    @page = params.fetch(:page, 1).to_i
  end

  def set_and_validate_tag_filter
    tag_param = params[:tags].presence
    return if tag_param.nil?

    tag = Tag.get(tag_param)

    if tag.present?
      @tag_filter = tag
    else
      render status: :bad_request
    end
  end
end
