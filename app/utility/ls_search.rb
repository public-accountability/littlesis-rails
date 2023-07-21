# frozen_string_literal: true

# Utility functions for searching
# TODO: move and combine functions from SearchController, EntitySearch and
# EntityMatcher into this module
module LsSearch
  # This un-escapes double quotes (")
  # When a user searches for a term on LittleSis, we use ThinkingSphinx's escape
  # helper function before submitting the query to sphinx.
  # However, we want to expose some of manticore's extended search functionality,
  # and therefore have to un-escape those query features we allow.
  def self.escape(query)
    ThinkingSphinx::Query
      .escape(query)
      .gsub('\\"', '"')
  end

  def self.generate_search_terms(entity)
    terms = entity.name_variations.map { |x| ThinkingSphinx::Query.escape(x) }

    if entity.person?
      terms << "#{ThinkingSphinx::Query.escape(entity.person.name_first)} * #{ThinkingSphinx::Query.escape(entity.person.name_last)}"
    end

    terms.map { |x| '(' + x + ')' }.join(' | ')
  end
end
