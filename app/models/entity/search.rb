# frozen_string_literal: true

# A wrapper around the default
# sphinx model search - Entity.search
class Entity
  module Search
    SIMILAR_ENTITIES_PRESENTER = proc do |e|
      { name: e.name,
        blurb: e.blurb,
        types: e.extension_ids[1..-1].map { |i| ExtensionDefinition.display_names.fetch(i) }.join(', '),
        slug: e.slug,
        id: e.id }
    end

    # String, Hash -> ThinkingShinx::Search
    # NOTE: used by SearchController
    def self.search(query, opt = {})
      EntitySearchService
        .new(query: query, **opt)
        .search
    end
  end
end
