class SearchController < ApplicationController
  before_filter :authenticate_user!, except: [:basic]

  def basic
    @q = (params[:q] or "").gsub(/\b(and|the|of)\b/, "")

    if @q.present?      
      q = Riddle::Query.escape(@q)
      page = (params[:page] or 1).to_i

      @entities = Entity.search(
        "@(name,aliases) #{q}", 
        page: page, 
        match_mode: :extended,
        with: { is_deleted: false },
        select: "*, weight() * (link_count + 1) AS link_weight",
        order: "link_weight DESC"
      )

      if page > 1
        @groups = []
        @lists = []
        @maps = []
      else
        admin = current_user.present? and current_user.has_legacy_permission("admin")
        list_is_admin = admin ? [0, 1] : 0
        @groups = Group.search("@(name,tagline,description,slug) #{q}", per: 50, match_mode: :extended)
        @lists = List.search("@(name,description) #{q}", per: 50, match_mode: :extended, with: { is_deleted: false, is_admin: list_is_admin, is_network: false })
        @maps = NetworkMap.search("@(title,description,index_data) #{q}", per: 100, match_mode: :extended, with: { is_deleted: false, is_private: false })
      end
    end

    respond_to do |format|
      format.html {    
        render "basic"
      }

      format.json {
        entities = @entities.map do |e|
          {
            id: e.id,
            name: e.name,
            description: e.blurb,
            summary: e.summary,
            primary_type: e.primary_ext,
            url: e.legacy_url
          }
        end

        render json: { entities: entities }
      }
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
end
