# frozen_string_literal: true

module EntityMatcher
  # Generators for Person and Org that
  # create Sphinx query strings
  module Query
    class Base < SimpleDelegator
      attr_reader :query
      alias to_s query

      # input: <Entity> | <String> | <Array>
      def initialize(arg)
        case arg
        when String, Array
          super(arg.dup)
        when Entity
          super(arg)
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

    # Simple query for last names
    class Names < Base
      # input: *args | <Array>
      def initialize(*args)
        raise ArgumentError if args.length.zero?

        if args.length == 1 && args.first.is_a?(Array)
          super(args.first)
        else
          super(args)
        end
      end

      def run
        each { |name| @parts << ThinkingSphinx::Query.wildcard(name) }
      end
    end

    class Org < Base
      def initialize(str)
        TypeCheck.check str, String
        @org_name = OrgName.parse(str)
        super(str)
      end

      def run
        @parts << ThinkingSphinx::Query.wildcard(@org_name.clean)
        @parts << @org_name.root if @org_name.root != @org_name.clean

        if @org_name.essential_words.length > 1
          @parts << @org_name.essential_words.join(' ')
        end
      end
    end
  end
end
