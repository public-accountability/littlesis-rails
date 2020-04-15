# frozen_string_literal: true

module EntityMatcher
  module Search
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

      evaluation_class = "EntityMatcher::Evaluation::#{primary_ext}".constantize
      test_case_class = "EntityMatcher::TestCase::#{primary_ext}".constantize

      # Adds a method 'evaluate_with' which accepts a test case,
      # to the sphinx search result object.
      #
      # This is approximately equal to (assuming primary_ext = 'Person') this method:
      #   def evaluate_with(test_case)
      #     map do |entity|
      #       EntityMatcher::Evaluation::Person.new(test_case, TestCase.person(entity)).result
      #      end
      #   end
      Entity
        .search("@(name,aliases,name_nick) ( #{query} )", options)
        .tap do |search_results|
          search_results.instance_exec do
            define_singleton_method :evaluate_with do |test_case|
              map do |entity|
                evaluation_class.new test_case, test_case_class.new(entity)
              end
            end
          end
      end
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
