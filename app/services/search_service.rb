# frozen_string_literal: true

class SearchService
  attr_reader :query, :escaped_query, :page, :admin, :tag_filter

  def initialize(query, page: 1, admin: false, tag_filter: nil)
    raise BlankQueryError if query.blank?

    @page = page
    @admin = admin
    @tag_filter = tag_filter
    @query = clean(query)
    @escaped_query = LsSearch.escape(@query)
  end

  def tags
    return @tags if defined?(@tags)

    @tags = Tag.search_by_names(@query)
  end

  def entities
    return @entities if defined?(@entities)

    entity_search_args = { query: @query, page: @page }
    entity_search_args[:tags] = @tag_filter if @tag_filter

    @entities = EntitySearchService.new(**entity_search_args).search
  end

  def lists
    return @lists if defined?(@lists)

    list_is_admin = @admin ? [0, 1] : 0
    @lists = List.search "@(name,description) #{@escaped_query}",
                         per_page: 50,
                         with: { is_deleted: false, is_admin: list_is_admin },
                         without: { access: Permissions::ACCESS_PRIVATE }
  end

  def maps
    return @maps if defined?(@maps)

    @maps = NetworkMap.search "@(title,description,index_data) #{@escaped_query}",
                              per_page: 50,
                              with: { is_deleted: false, is_private: false }
  end

  private

  def clean(query)
    query
      .gsub(/\b(and|the|of)\b/, '')
      .gsub(/[ ]{2,}/, ' ')
  end

  class BlankQueryError < Exceptions::LittleSisError; end
end
