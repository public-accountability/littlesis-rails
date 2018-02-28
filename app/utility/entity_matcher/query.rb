module EntityMatcher
  # Generators for Person and Org that
  # create Sphinx query strings
  module Query
    class Base < SimpleDelegator
      attr_reader :query
      alias to_s query

      # input: <Entity> | <String>
      def initialize(entity_or_string)
        case entity_or_string
        when String
          super(entity_or_string.dup)
        when Entity
          super(entity_or_string)
        else
          raise ArgumentError
        end
        # components of the query to be separated by OR
        @parts = []
        # overwrite this method to populate the @parts instance var
        run
        create_query
      end

      protected

      def run
        raise NotImplementedError
      end

      private

      def create_query
        @query = @parts
                   .uniq
                   .map { |x| surround(x) }
                   .join(' | ')
      end

      def surround(x)
        "(#{x})"
      end
    end

    class Person < Base
      # Fields on Person that we will delgate for easier access
      PERSON_FIELDS = %I[name_first name_last name_middle name_prefix name_suffix name_nick name_maiden].freeze
      delegate(*PERSON_FIELDS, to: :person)

      def run
        @parts << name
        @parts << first_last if first_last != name
        @parts << first_last_suffix if name_suffix.present?
        @parts << prefix_lastname if name_prefix.present?
      end

      private

      def prefix_lastname
        "#{name_prefix} #{name_last}"
      end

      def first_last_suffix
        "#{name_first} #{name_last} #{name_suffix}"
      end

      def first_last
        "#{name_first} #{name_last}"
      end
    end

    # Simple query building for one-word strings
    class LastName < Base
      def run
        @parts << ThinkingSphinx::Query.wildcard(__getobj__)
      end
    end

    class Org < Base
    end
  end
end
