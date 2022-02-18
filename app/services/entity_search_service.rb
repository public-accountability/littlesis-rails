# frozen_string_literal: true

class EntitySearchService
  ONLY_NUMBERS = /\A[[:digit:]]+\Z/.freeze

  DEFAULT_OPTIONS = {
    with: { is_deleted: false },
    fields: %w[name aliases],
    num: 15,
    page: 1,
    tags: nil,
    regions: nil,
    exclude_list: nil,
    populate: false
  }.freeze

  attr_reader :query, :options, :search_options, :search
  alias_attribute :results, :search

  # Class Methods

  def initialize(query:, **kwargs)
    @query = LsSearch.escape(query)
    @options = DEFAULT_OPTIONS.deep_merge(kwargs)

    @search_options = {
      with: @options[:with],
      with_all: {},
      per_page: @options[:num].to_i,
      page: @options[:page].to_i,
      populate: @options[:populate],
      select: '*, weight() * (link_count + 1) AS link_weight',
      order: 'link_weight DESC'
    }

    @search_query = "@(#{@options[:fields].join(',')}) #{@query}"

    parse_tags
    parse_regions
    parse_exclude_list

    @search_options.delete(:with_all) if @search_options[:with_all].empty?

    # If the query is an integer, assume that it is the ID of an entity
    if ONLY_NUMBERS.match? query.strip
      @search = Kaminari.paginate_array([Entity.find(query.strip)]).page(1)
    else
      @search = Entity.search @search_query, @search_options
    end
    freeze
  end

  # returns [{}] with two options for additional fields: image_url and is_parent
  def to_array(image_url: false, parent: false)
    @search.map do |entity|
      entity.to_hash(image_url: image_url, url: true).tap do |hash|
        hash.merge!(is_parent: entity.parent?) if parent
      end
    end
  end

  private

  # This instructs sphinx to exlude all entities that are already on provided list.
  def parse_exclude_list
    return if @options[:exclude_list].nil?

    ids_to_exclude = ListEntity.where(list_id: @options[:exclude_list]).pluck(:entity_id)
    @search_options[:without] = { sphinx_internal_id: ids_to_exclude }
  end

  def parse_tags
    return if @options[:tags].blank?

    TypeCheck.check @options[:tags], [String, Array]

    @options[:tags] = @options[:tags].split(',') if @options[:tags].is_a?(String)

    @options[:tags].map! do |tag|
      t = Tag.find_by_name(tag)
      Rails.logger.warn "[EntitySearchService]: unknown tag: #{tag}" if t.nil?
      t.try(:id)
    end.compact!

    if @options[:tags]&.length&.positive?
      @search_options[:with_all][:tag_ids] = @options[:tags]
    end
  end

  def parse_regions
    return if @options[:regions].blank?

    @options[:regions] = @options[:regions].split(',') if @options[:regions].is_a?(String)

    @search_options[:with_all][:regions] = @options[:regions].map(&:to_i)
  end
end
