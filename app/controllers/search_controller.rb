class SearchController < ApplicationController
  before_filter :auth, except: [:basic]

  def basic
    @q = (params[:q] or "").gsub(/\b(and|the|of)\b/, "")

    if @q.present?      
      q = Riddle::Query.escape(@q)

      admin = current_user.present? and current_user.has_legacy_permission("admin")
      list_is_admin = admin ? [0, 1] : 0

      @groups = Group.search("@(name,tagline,description,slug) #{q}", match_mode: :extended)
      @lists = List.search("@(name,description) #{q}", match_mode: :extended, with: { is_deleted: false, is_admin: list_is_admin, is_network: false })
      @entities = Entity.search("@(name,aliases) #{q}", match_mode: :extended, with: { is_deleted: false })
      @maps = NetworkMap.search("@(title,description,index_data) #{q}", match_mode: :extended, with: { is_deleted: false, is_private: false })
    end
  end
end
