module EntityMatcher
  ##
  # Module contain wrapper objects for the *test case*, the
  # are is the input entity
  #
  # They can be initalized with an Entity (use case: searching for duplicates) or strings.
  # Person test cases can be initalized with hash containing the attributes
  # used in the +Person+ model
  #
  module TestCase
    class Base
      attr_reader :primary_ext, :entity

      # Primary_ext is required unless an +Entity+ is provided
      def initialize(name_or_entity, primary_ext: nil)
        @primary_ext = standardize_primary_ext(name_or_entity, primary_ext)
        @entity = name_or_entity if name_or_entity.is_a? Entity
      end

      private

      def standardize_primary_ext(name_or_entity, primary_ext)
        return name_or_entity.primary_ext if name_or_entity.is_a? Entity
        ext = primary_ext.to_s.capitalize
        return ext if %w[Org Person].include? ext
        raise MissingOrInvalidPrimaryExtError
      end
    end

    class PersonTestCase < Base
    end

    ##
    # Exceptions
    #
    class MissingOrInvalidPrimaryExtError < StandardError; end
  end
end
