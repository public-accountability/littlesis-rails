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

      def ts_escape(x)
        ThinkingSphinx::Query.escape(x)
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
      def run
        @parts << name
        @parts << "#{person.name_first} #{person.name_last}"
        if person.name_suffix.present?
          @parts << "#{person.name_first} #{person.name_last} #{person.name_suffix}"
        end
        @parts << "#{person.name_prefix} #{person.name_last}" if person.name_prefix.present?
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
        @parts << ThinkingSphinx::Query.wildcard(ts_escape(@org_name.clean))
        @parts << ts_escape(@org_name.root) if ts_escape(@org_name.root) != ts_escape(@org_name.clean)

        if @org_name.essential_words.length > 1
          @parts << @org_name.essential_words.map { |x| ts_escape(x) }.join(' ')
        end
      end
    end
  end
end
