# frozen_string_literal: true

class SearchController < ApplicationController
  before_action :set_page, only: [:basic]

  def basic
    @query = params[:q].presence
    @tag_filter = (params[:tags].presence || params[:tag].presence)
    user_is_admin = current_user&.admin?

    # return render(status: :bad_request) if @tag_filter && Tag.get(params[:tags]).nil?

    begin
      service = SearchService.new(@query, page: @page, admin: user_is_admin, tag_filter: @tag_filter)

      @entities = service.entities

      # Only entities are displayed if on page 2+ or if there is a tag filter
      # Entities are the only model that can be filtered by tag or paginated
      if @page == 1 && !@tag_filter
        @lists = service.lists
        @maps = service.maps
        @tags = service.tags
      else
        @lists = @maps = @tags = []
      end

      @no_results = (@lists.count + @entities.count + @maps.count + @tags.count).zero?
    rescue SearchService::BlankQueryError
    # just re-render the blank search page
    rescue ThinkingSphinx::SyntaxError => e
      logger.warn "ThinkingSphinx::SyntaxError: #{e}"
      @sphinx_error = true
    end

    respond_to do |format|
      format.html { render 'basic' }

      format.json do
        entities = @entities.map { |entity| entity.to_hash(image_url: true) }
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

  def set_page
    @page = params.fetch(:page, 1).to_i
  end
end
