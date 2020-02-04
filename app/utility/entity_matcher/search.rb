# frozen_string_literal: true

module EntityMatcher
  module Search
    SEARCH_OPTS = {
      :per_page => 400,
      :ranker => :none,
      :populate => true,
      :with => { is_deleted: false }
    }.freeze

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

    # str --> ThinkginSphinx
    # Search database for potential matches
    def self.search(query, primary_ext:)
      Entity.search("@(name,aliases,name_nick) ( #{query} )",
                    SEARCH_OPTS
                      .deep_merge(:sql => sql_include(primary_ext))
                      .deep_merge(:with => { primary_ext: primary_ext }))
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
