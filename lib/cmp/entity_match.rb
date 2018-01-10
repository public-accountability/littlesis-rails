module Cmp
  class EntityMatch
    attr_reader :search_results
    delegate :count, :empty?, :to => :search_results

    def initialize(name:, primary_ext:)
      raise ArgumentError, "Invalid primary_ext" unless %w[Org Person].include? primary_ext
      @name = name
      @search_options = { :with => { primary_ext: "'#{primary_ext}'", is_deleted: false } }.freeze
      @search_results = perform_search
    end

    def first
      @search_results.first unless empty?
    end

    private

    def perform_search
      Entity::Search.search @name, @search_options
    end
  end
end
