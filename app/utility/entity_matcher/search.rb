# frozen_string_literal: true

module EntityMatcher
  module Search
    # == These helpers use the classes in EntityMatcher::Query
    #    cast the input into a formated sphinx query

    def self.by_entity(entity)
      public_send("by_#{entity.primary_ext.downcase}", entity)
    end

    def self.by_person(person)
      search EntityMatcher::Query::Person.new(person).to_s, primary_ext: 'Person'
    end

    def self.by_org(org)
      search EntityMatcher::Query::Org.new(org).to_s, primary_ext: 'Org'
    end

    def self.by_name(*names)
      search EntityMatcher::Query::Names.new(*names).to_s, primary_ext: 'Person'
    end

    # str --> ThinkingSphinx
    # Search database for potential matches
    def self.search(query, primary_ext:, per_page: 400)
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
