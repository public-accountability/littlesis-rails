# frozen_string_literal: true

# An set of +EvaluationResult+
# It sorts the results upon initalization
module EntityMatcher
  class EvaluationResultSet
    attr_reader :results
    extend Forwardable

    def_delegators :@results, :each, :first, :second, :map, :size, :count, :empty?, :last

    # input: array of EvaluationResult::Person or EvaluationResult::Org
    def initialize(evaluation_results)
      check_argument(evaluation_results)
      @results = evaluation_results.sort
    end

    def to_a
      @results
    end

    # This removes all results that don't contain the provided attributes
    # It modifies the instance and returns it
    # input: Symbols
    def filter(*attributes)
      check_filter_attributes(attributes)

      @results.select! do |result|
        passes_filter = true

        attributes.each do |attribute|
          unless result.public_send(attribute)
            passes_filter = false
            break
          end
        end
        passes_filter
      end

      self
    end

    def slice!(amount = 5)
      @results.slice!(0, amount)
    end

    # In order for the set to be considered automatachable
    # the set must contain only one result that can be automatched.
    # If there are two (or more) results, then there is no way to know which
    # one is better without human intervention
    def automatchable?
      @results&.first&.automatch? && !@results&.second&.automatch?
    end

    # Returns the automatched EvalutionResult
    # if set is automatchable
    def automatch
      return @results.first if automatchable?
    end

    def as_json(options = {})
      super(options)
        .merge!('automatchable' => automatchable?)
    end

    private

    def check_argument(evaluation_results)
      TypeCheck.check evaluation_results, Array
      TypeCheck.check evaluation_results&.first,
                      [NilClass, EvaluationResult::Person, EvaluationResult::Org]
    end

    def check_filter_attributes(attrs)
      attrs.each do |attr|
        TypeCheck.check attr, Symbol
        unless EvaluationResult::PERSON_ATTRS.include?(attr) || EvaluationResult::ORG_ATTRS.include?(attr)
          raise ArgumentError, "Invalid evaluation result attribute: #{attr}"
        end
      end
    end
  end
end
