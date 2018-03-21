# frozen_string_literal: true

# An set of +EvaluationResult+
# It sorts the results upon initalization
module EntityMatcher
  class EvaluationResultSet
    attr_reader :results
    extend Forwardable

    def_delegators :@results, :each, :first, :second

    def initialize(evaluation_results)
      check_argument(evaluation_results)
      @results = evaluation_results.sort
    end

    def to_a
      @results
    end

    private

    def check_argument(evaluation_results)
      TypeCheck.check evaluation_results, Array
      TypeCheck.check evaluation_results&.first,
                      [NilClass, EvaluationResult::Person, EvaluationResult::Org]
    end
  end
end
