require 'active_support/concern'

module SimilarEntities
  extend ActiveSupport::Concern

  SIMILAR_ENTITY_FIELD_WEIGHTS = { name: 15, aliases: 10, blurb: 3, summary: 1 }.freeze

  # -> [ <Entity> ]
  def similar_entities(per_page = 5)
    Entity.search(generate_search_terms,
                  :with => { primary_ext: "'#{primary_ext}'", is_deleted: false },
                  :without => { sphinx_internal_id: id },
                  :per_page => per_page,
                  :select => "*, weight() + (link_count * 20) AS link_weight",
                  :order => "link_weight DESC",
                  :field_weights => SIMILAR_ENTITY_FIELD_WEIGHTS)
  end

  private

  # -> str
  # - add basic version of name "First Last"
  # - add versions of organization names with common suffixes removed
  # - escapes and adds wildcard to names
  # - add version of names without wildcards
  def generate_search_terms
    alias_names = aliases.map(&:name)
    alias_names
      .dup
      .tap { |names| names.append("#{person.name_first} #{person.name_last}") if person? }
      .tap { |names| names.concat(names.map { |name| Org.strip_name(name) }) if org? }
      .map { |name| ThinkingSphinx::Query.escape(name) }
      .map { |name| "(#{ThinkingSphinx::Query.wildcard(name)})" }
      .tap { |names| names.concat(alias_names.map { |n| "(#{ThinkingSphinx::Query.escape(n)})" }) }
      .join(' | ')
  end
end
