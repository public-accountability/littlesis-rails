# frozen_string_literal: true

module EntityMatcher
  ##
  # Module contain wrapper objects for the *test case*
  #
  # They can be initalized with an Entity (use case: searching for duplicates), strings or hashes.
  # The hashes have to contain the attributes used in the +Person+ model
  #
  module TestCase
    class Person
      BLANK_NAME_HASH = ActiveSupport::HashWithIndifferentAccess
                          .new(name_prefix: nil,
                               name_first: nil,
                               name_middle: nil,
                               name_last: nil,
                               name_suffix: nil,
                               name_nick: nil).freeze

      attr_reader :entity, :name
      delegate :fetch, to: :name

      # input: Entity | String | Hash
      def initialize(input)
        case input
        when Entity
          raise WrongEntityTypeError unless input.person?
          @entity = input
          @name = ActiveSupport::HashWithIndifferentAccess.new(@entity.person.name_attributes)
        when String
          @name = NameParser.new(input).to_indifferent_hash
        when Hash
          validate_input_hash(input)
          @name = BLANK_NAME_HASH.merge(input)
        else
          raise ArgumentError
        end
      end

      private

      def validate_input_hash(h)
        unless (h[:name_first] || h['name_first']) && (h[:name_last] || h['name_last'])
          raise InvalidPersonHash
        end
      end
    end

    ##
    # Exceptions
    #
    class WrongEntityTypeError < StandardError; end
    class InvalidPersonHash < StandardError; end
  end
end
