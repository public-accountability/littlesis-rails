# Provides Entity::Search.search
# as well as entity#similar_entities
module EntitySearch

  def similar_entities(per_page = 5)
    @similar_entities ||= Entity::Search.similar_entities(self, per_page: per_page)
  end

  private

  def generate_search_terms
    search_terms = []
    alias_names = aliases.map(&:name)

    search_terms.concat(alias_names.map { |n| ts_escape(n) })
    search_terms.append(ts_escape("#{person.name_first} #{person.name_last}")) if person?
    search_terms.append(ts_surround_escape("#{person.name_first} * #{person.name_last}")) if person?

    search_terms.concat(alias_names.map { |n| ts_escape(Org.strip_name(n)) }) if org?
    search_terms.append("*#{ts_escape(self.name)}*") if org?

    search_terms.uniq.map { |term| "(#{term})" }.join(' | ')
  end

  def ts_surround_escape(x)
    '"' + ts_escape(x) + '"'
  end

  def ts_escape(x)
    ThinkingSphinx::Query.escape(x)
  end

  # A wrapper around the default
  # sphinx model search - Entity.search
  class Search
    DEFAULT_SEARCH_OPTIONS = {
      with: { is_deleted: false },
      fields: 'name,aliases',
      num: 15,
      page: 1
    }.freeze

    DEFAULT_SIMILAR_ENTITIES_PER_PAGE = 5
    SIMILAR_ENTITY_FIELD_WEIGHTS = { name: 15, aliases: 10, blurb: 3 }.freeze

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
      options = DEFAULT_SEARCH_OPTIONS.merge(opt)
      Entity.search(
        "@(#{options[:fields]}) #{ts_escape(query)}",
        match_mode: :extended,
        with: options[:with],
        per_page: options[:num],
        page: options[:page],
        select: '*, weight() * (link_count + 1) AS link_weight',
        order: 'link_weight DESC'
      )
    end

    # input: Entity | Integer, [ query<String> ], [ per_page<Integer> ]
    # output: ThinkingSphinx::Search | Array
    # Searches for similar entities for the provided entity
    # If no query is provided it will generate one via entity.send(:generate_search_terms)
    def self.similar_entities(entity_or_id, query: nil, per_page: DEFAULT_SIMILAR_ENTITIES_PER_PAGE)
      entity = Entity.entity_for(entity_or_id)
      q = query.present? ? ts_escape(query) : entity.send(:generate_search_terms)
      Entity.search("@!summary #{q}",
                    :with => { primary_ext: "'#{entity.primary_ext}'", is_deleted: false },
                    :without => { sphinx_internal_id: entity.id },
                    :per_page => per_page,
                    :ranker => :sph04,
                    :sql => { :include => :extension_records },
                    :select => "*, weight() + (link_count * 10) AS link_weight",
                    :order => "link_weight DESC",
                    :field_weights => SIMILAR_ENTITY_FIELD_WEIGHTS,
                    # needed in order to for the error rescues to work
                    # see: https://github.com/pat/thinking-sphinx/issues/180
                    :populate => true)

    # If a sphinx encounters an error, we will ignore it and return an empty array
    rescue ThinkingSphinx::ConnectionError => err
      Rails.logger.error "Cannot connect to Sphinx :( \n #{err.message}"
      return []
    rescue ThinkingSphinx::SphinxError => err
      Rails.logger.error "A Sphinx Error occured while attempting to get similar entities for entity #{entity.id}:\n #{err.message}"
      return []
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

    private_class_method def self.ts_escape(x)
      ThinkingSphinx::Query.escape(x)
    end
  end
end
