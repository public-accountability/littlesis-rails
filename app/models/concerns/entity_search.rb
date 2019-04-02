# frozen_string_literal: true

# Provides Entity::Search.search
# as well as entity#similar_entities
module EntitySearch

  def similar_entities(per_page = 5)
    @similar_entities ||= SimilarEntitiesService
                            .new(self, per_page: per_page)
                            .similar_entities
  end

  def generate_search_terms
    ts_escape = ->(x) { LsSearch.escape(x) }
    ts_surround_escape = ->(x) { '"' + LsSearch.escape(x) + '"' }

    search_terms = []
    alias_names = aliases.map(&:name)

    search_terms.concat(alias_names.map(&ts_escape))  #{ |n| ts_escape(n) })
    search_terms.append(ts_escape.call("#{person.name_first} #{person.name_last}")) if person?
    search_terms.append(ts_surround_escape.call("#{person.name_first} * #{person.name_last}")) if person?

    search_terms.concat(alias_names.map { |n| ts_escape.call(Org.strip_name(n)) }) if org?
    search_terms.append("*#{ts_escape.call(self.name)}*") if org?

    search_terms.uniq.map { |term| "(#{term})" }.join(' | ')
  end

  # A wrapper around the default
  # sphinx model search - Entity.search
  class Search
    SIMILAR_ENTITIES_PRESENTER = proc do |e|
      {
        name: e.name,
        blurb: e.blurb,
        types: e.extension_ids[1..-1].map { |i| ExtensionDefinition.display_names.fetch(i) }.join(', '),
        slug: e.slug,
        id: e.id
      }
    end

    # String, Hash -> ThinkingShinx::Search
    # NOTE: used by SearchController
    def self.search(query, opt = {})
      EntitySearchService
        .new(query: query, **opt)
        .search
    end

    def self.entity_with_summary(e)
      {   id: e.id,
          name: e.name,
          description: e.blurb,
          summary: e.summary,
          primary_type: e.primary_ext,
          url: e.url }
    end

    def self.entity_no_summary(e)
      {   id: e.id,
          name: e.name,
          description: e.blurb,
          primary_type: e.primary_ext,
          url: e.url }
    end
  end
end
