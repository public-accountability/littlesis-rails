require 'active_support/concern'

module SimilarEntities
  extend ActiveSupport::Concern

  SIMILAR_ENTITY_FIELD_WEIGHTS = { name: 15, aliases: 10, blurb: 3 }.freeze

  def similar_entities(per_page = 5)
    @similar_entities ||= _similar_entities(per_page)
  end
  # -> [ <Entity> ]
  def _similar_entities(per_page)
    Entity.search("@!summary #{generate_search_terms}",
                  :with => { primary_ext: "'#{primary_ext}'", is_deleted: false },
                  :without => { sphinx_internal_id: id },
                  :per_page => per_page,
                  :ranker => :sph04,
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
    Rails.logger.error "A Sphinx Error occured while attempting to get similar entities for entity #{id}:\n #{err.message}"
    return []
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
end
