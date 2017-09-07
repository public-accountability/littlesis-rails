class SearchController < ApplicationController
  before_filter :authenticate_user!, except: [:basic]
  before_action :set_page, only: [:basic]
  before_action :set_initial_search_values, only: [:basic]

  def basic
    @q = (params[:q] or "").gsub(/\b(and|the|of)\b/, "")
    @cant_find = params[:q].present? && @q.empty?

    if @q.present?
      if @page > 1
        entities_search(@q) # only show entities
      else
        perform_search(@q)
      end
    end

    respond_to do |format|
      format.html { render "basic" }

      format.json do
        entities = @entities.map { |e| Entity::Search.entity_with_summary(e) }
        render json: { entities: entities }
      end
    end
  end

  def entity_search
    return head :bad_request unless params[:q].present?

    options = {}
    options[:with] = { is_deleted: false, primary_ext: "'#{params[:ext].titleize}'" } if params[:ext]
    options[:num] = params[:num] if params[:num]

    search_results = Entity::Search.search(params[:q], options)

    if params[:no_summary]
      render json: search_results.map { |e| Entity::Search.entity_no_summary(e) }
    else
      render json: search_results.map { |e| Entity::Search.entity_with_summary(e) }
    end
  end

  private

  def perform_search(query)
    q = ThinkingSphinx::Query.escape(query)
    tags_search(query) if current_user&.admin?
    entities_search(query)
    groups_search(q)
    lists_search(q)
    maps_search(q)
  end

  def tags_search(query)
    @tags = Tag.search_by_names(query)
  end

  # unlike groups, lists, and maps, Entity::Search takes
  # the "raw" query before it has been escaped.
  def entities_search(query)
    @entities = Entity::Search.search(query, page: @page)
  end

  def groups_search(q)
    @groups = Group.search("@(name,tagline,description,slug) #{q}", per: 50, match_mode: :extended)
  end

  def lists_search(q)
    list_is_admin = current_user&.admin? ? [0, 1] : 0
    @lists = List.search("@(name,description) #{q}",
                         per: 50,
                         match_mode: :extended,
                         with: { is_deleted: false, is_admin: list_is_admin, is_network: false },
                         without: { access: Permissions::ACCESS_PRIVATE })
  end

  def maps_search(q)
    @maps = NetworkMap.search("@(title,description,index_data) #{q}",
                              per: 100,
                              match_mode: :extended,
                              with: { is_deleted: false, is_private: false })
  end

  def set_initial_search_values
    @entities = []
    @groups = []
    @lists = []
    @maps = []
    @tags = []
  end

  def set_page
    @page = (params[:page] or 1).to_i
  end
end
