# frozen_string_literal: true

module EntityMatcher
  module Search
    # == These helpers use the classes in EntityMatcher::Query
    #    cast the input into a formated sphinx query
    def self.by_entity(entity)
      search EntityMatcher::Query.entity(entity), primary_ext: entity.primary_ext
    end

    def self.by_person_hash(hash)
      search EntityMatcher::Query.person_hash(hash), primary_ext: 'Person'
    end

    def self.by_person_name(name)
      search EntityMatcher::Query.person_name(name), primary_ext: 'Person'
    end

    def self.by_org_name(name)
      search EntityMatcher::Query.org_name(name), primary_ext: 'Org'
    end

    def self.by_name(*names, primary_ext:)
      search EntityMatcher::Query.names(*names), primary_ext: primary_ext
    end

    # str --> ThinkingSphinx
    # Search database for potential matches
    def self.search(query, primary_ext:, per_page: 250)
      options = {
        :per_page => per_page,
        :ranker => :none,
        :populate => true,
        :sql => sql_include(primary_ext),
        :with => { is_deleted: false, primary_ext: primary_ext }
      }

      Entity.search("@(name,aliases,name_nick) ( #{query} )", options)
    end

    def self.sql_include(primary_ext)
      case primary_ext
      when 'Person'
        { :include => [:links, :person] }
      when 'Org'
        { :include => [:links, :org, :aliases] }
      else
        raise TypeError
      end
    end

    private_class_method :search, :sql_include
  end
end
