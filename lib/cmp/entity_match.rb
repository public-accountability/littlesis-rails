module Cmp
  class EntityMatch
    delegate :count, :empty?, :to => :search_results

    def initialize(name:, primary_ext:)
      raise ArgumentError, "Invalid primary_ext" unless %w[Org Person].include? primary_ext
      @name = name
      @search_options = { :with => { primary_ext: "'#{primary_ext}'", is_deleted: false } }.freeze
      search_results
    end

    def match
      first
    end

    def first
      search_results.first unless empty?
    end

    def second
      search_results.second unless count < 2
    end

    def search_results
      return @search_results if defined? @search_results
      @search_results = Entity::Search.search(@name, @search_options)
    end
  end
end
