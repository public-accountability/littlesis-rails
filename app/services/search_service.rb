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

    @tags = Tag.fuzzy_search(@query)
  end

  def entities
    return @entities if defined?(@entities)

    entity_search_args = { query: @query, page: @page, populate: true }
    entity_search_args[:tags] = @tag_filter if @tag_filter

    @entities = EntitySearchService.new(**entity_search_args).search
  end

  def lists
    return @lists if defined?(@lists)

    @lists = List.search(
      "@(name,description) #{@escaped_query}",
      per_page: 10,
      with: { is_deleted: false  },
      without: { access: Permissions::ACCESS_PRIVATE },
      order: "is_featured DESC",
      populate: true
    )
  end

  def maps
    return @maps if defined?(@maps)

    @maps = OligrapherSearchService.run(@query, limit: 10)
  end

  private

  # Removes the words "and", "the", and "of" from the query, except when they
  # appear within quoted phrases.
  #
  # e.g. the input query [university of california "school of law"]
  # should result in [university california "school of law"]
  def clean(query)
    # second argument to split() keeps trailing nil array elements
    parts = query.split('"', -1)

    # when split by quotation marks, even indexed parts are outside of quotes
    clean_parts = parts.each_with_index.map do |part, i|
      i.even? ? part.gsub(/\b(and|the|of)\b/, '').gsub(/[ ]{2,}/, ' ') : part
    end

    clean_parts.join('"')
  end

  class BlankQueryError < Exceptions::LittleSisError; end
end
