# frozen_string_literal: true

class SearchService
  attr_reader :query, :escaped_query, :page, :admin

  def initialize(query, page: 1, admin: false)
    raise BlankQueryError if query.blank?

    @page = page
    @admin = admin
    @query = clean(query)
    @escaped_query = LsSearch.escape(@query)
  end

  def tags
    return @tags if defined?(@tags)

    @tags = Tag.search_by_names(@query)
  end

  def entities
    return @entities if defined?(@entities)

    @entities = EntitySearchService.new(query: @query, page: @page).search
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
