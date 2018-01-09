module Cmp
  class EntityMatch
    SEARCH_OPTIONS = { :with => { primary_ext: "'Org'", is_deleted: false } }.freeze

    attr_reader :search_results
    delegate :count, :empty?, :to => :search_results

    def initialize(name)
      @name = name
      @search_results = perform_search
    end

    private

    def perform_search
      @_results ||= Entity::Search.search(@name, SEARCH_OPTIONS)
    end
  end
end
