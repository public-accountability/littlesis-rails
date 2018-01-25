module Cmp
  class EntityMatch
    MATCHES = YAML.load_file(Rails.root.join('data', 'cmp_matches.yml'))
    delegate :count, :empty?, :to => :search_results

    def initialize(name:, primary_ext:, cmpid:)
      raise ArgumentError, "Invalid primary_ext" unless %w[Org Person].include? primary_ext
      @name = name
      @search_options = { :with => { primary_ext: "'#{primary_ext}'", is_deleted: false } }.freeze
      @cmpid = cmpid.to_s
      search_results
    end

    def match
      return nil unless has_match?
      return Entity.find(self.class.matches.dig(@cmpid, 'entity_id')) if self.class.matches.key?(@cmpid)
      return first
    end

    def first
      search_results.first unless empty?
    end

    def second
      search_results.second unless count < 2
    end

    def has_match? # rubocop:disable PredicateName
      self.class.matches.key?(@cmpid) || search_results.present?
    end

    def search_results
      return @search_results if defined? @search_results
      @search_results = Entity::Search.search(@name, @search_options)
    end

    def self.matches
      @_matches ||= MATCHES.each_with_object({}) do |h, memo|
        memo.store(h['cmpid'].to_s, h)
      end
    end
  end
end
 
