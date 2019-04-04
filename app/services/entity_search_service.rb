# frozen_string_literal: true

class EntitySearchService
  DEFAULT_OPTIONS = {
    with: { is_deleted: false },
    fields: %w[name aliases],
    tags: nil,
    num: 15,
    page: 1
  }.freeze

  attr_accessor :query, :options, :tags

  delegate :fetch, to: :@options

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
    @options = DEFAULT_OPTIONS.deep_merge(kwargs)
    parse_tags
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
    { with: search_options_with,
      per_page: @options[:num].to_i,
      page: @options[:page].to_i,
      select: '*, weight() * (link_count + 1) AS link_weight',
      order: 'link_weight DESC' }
  end

  def search_options_with
    if @options[:tags]&.length&.positive?
      @options[:with].merge(tag_ids: @options[:tags])
    else
      @options[:with]
    end
  end

  def parse_tags
    return if @options[:tags].nil?

    TypeCheck.check @options[:tags], [String, Array]

    @options[:tags] = @options[:tags].split(',') if @options[:tags].is_a?(String)

    @options[:tags].map! do |tag|
      Tag.get(tag).tap do |t|
        Rails.logger.warn "[EntitySearchService]: unknown tag: #{tag}" if t.nil?
      end
    end

    @options[:tags].compact!
    @options[:tags].map!(&:id)
  end
end
