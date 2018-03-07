# frozen_string_literal: true

module EntityMatcher
  ##
  # Module containing wrapper objects for the *test case*
  #
  # They can be initalized with an Entity (use case: searching for duplicates), strings or hashes.
  # The hashes must contain the attributes used in the +Person+ model
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

      attr_reader :entity, :name, :associated_entities, :keywords
      delegate :fetch, to: :name

      # calling .first, .last, etc. returns upcased versions of the name component
      %i[prefix first middle last suffix nick].each do |name_component|
        define_method(name_component) do
          fetch("name_#{name_component}")&.upcase
        end
      end

      # input: Entity | String | Hash
      def initialize(input, associated: nil, keywords: [])
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
          raise TypeError
        end
        
        @keywords = keywords
        parse_associated(associated)
      end

      private

      def validate_input_hash(h)
        unless (h[:name_first] || h['name_first']) && (h[:name_last] || h['name_last'])
          raise InvalidPersonHash
        end
      end

      # Associated entites can be used to help determined matches
      def parse_associated(associated)
        # if no associated entites are included in the intilzation phase,
        # they will be automatically added in the input is a entity
        if associated.blank?
          if @entity
            @associated_entities = @entity.links.map(&:entity2_id)
          else
            @associated_entities = []
          end
        else
          # associated can be either an array or mix of integers, entities, and strings
          @associated_entities = Array.wrap(associated).map do |x|
            x.respond_to?(:id) ? x.id.to_i : x.to_i
          end
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
