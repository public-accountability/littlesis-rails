module EntitySearch
  # A wrapper around the default
  # sphinx model search - Entity.search
  class Search
    DEFAULT_SEARCH_OPTIONS = {
      with: { is_deleted: false },
      fields: 'name,aliases',
      num: 15,
      page: 1
    }.freeze

    # String, Hash -> ThinkingShinx::Search
    # NOTE: used by SearchController
    def self.search(query, opt = {})
      q = ThinkingSphinx::Query.escape(query)
      options = DEFAULT_SEARCH_OPTIONS.merge(opt)
      Entity.search(
        "@(#{options[:fields]}) #{q}",
        match_mode: :extended,
        with: options[:with],
        per_page: options[:num],
        page: options[:page],
        select: '*, weight() * (link_count + 1) AS link_weight',
        order: 'link_weight DESC'
      )
    end

    def self.entity_with_summary(e)
      {   id: e.id,
          name: e.name,
          description: e.blurb,
          summary: e.summary,
          primary_type: e.primary_ext,
          url: e.legacy_url }
    end

    def self.entity_no_summary(e)
      {   id: e.id,
          name: e.name,
          description: e.blurb,
          primary_type: e.primary_ext,
          url: e.legacy_url }
    end
  end
end
