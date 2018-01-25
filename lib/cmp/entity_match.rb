module Cmp
  class EntityMatch
    MATCHES = YAML.load_file(Rails.root.join('data', 'cmp_matches.yml'))
    delegate :count, :empty?, :to => :search_results

    def initialize(name:, primary_ext:, cmpid:)
      raise ArgumentError, "Invalid primary_ext" unless %w[Org Person].include? primary_ext
      @name = name
      @primary_ext = primary_ext
      @search_options = { :with => { primary_ext: "'#{primary_ext}'", is_deleted: false } }.freeze
      @cmpid = cmpid.to_s
      search_results
    end

    def match
      return nil unless has_match?
      if self.class.matches.key?(@cmpid)
        entity_id = self.class.matches.dig(@cmpid, 'entity_id')
        return create_new_entity if entity_id == 'NEW'
        return Entity.find(entity_id)
      end
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

    private

    def create_new_entity
      Entity.create!(name: @name, primary_ext: @primary_ext, last_user_id: Cmp::CMP_SF_USER_ID)
    end
  end
end
