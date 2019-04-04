# frozen_string_literal: true

class EntitySearchService
  DEFAULT_SEARCH_OPTIONS = {
    with: { is_deleted: false },
    fields: %w[name aliases],
    num: 15,
    page: 1
  }.freeze

  attr_accessor :query, :options

  # Class Methods

  def self.entity_with_summary(e)
    { id: e.id,
      name: e.name,
      description: e.blurb,
      summary: e.summary,
      primary_type: e.primary_ext,
      url: e.url }
  end

  def self.entity_no_summary(e)
    { id: e.id,
      name: e.name,
      description: e.blurb,
      primary_type: e.primary_ext,
      url: e.url }
  end

  def initialize(query: nil, **kwargs)
    @query = query
    @options = DEFAULT_SEARCH_OPTIONS.deep_merge(kwargs)
  end

  def search
    raise ArgumentError, 'Blank search query' if query.blank?

    Entity.search search_query, search_options
  end

  private

  def search_query
    "@(#{@options[:fields].join(',')}) #{LsSearch.escape(@query)}"
  end

  def search_options
    { with: @options[:with],
      per_page: @options[:num].to_i,
      page: @options[:page].to_i,
      select: '*, weight() * (link_count + 1) AS link_weight',
      order: 'link_weight DESC' }
  end
end
