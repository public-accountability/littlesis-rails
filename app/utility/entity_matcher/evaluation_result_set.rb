# frozen_string_literal: true

# An set of EvaluationResult
# It sorts the results upon initalization
module EntityMatcher
  class EvaluationResultSet
    attr_reader :results
    extend Forwardable

    def_delegators :@results, :each, :first, :second

    def initialize(evaluation_results)
      check_argument(evaluation_results)

      # the sorting algorithm puts "highest" match
      # in last position of the array (ascending order)
      # But practically it makes more sense to think of the
      # 'first' element of the results as the item we are interested in
      # therefore we reverse the array afterwards
      @results = evaluation_results.sort.reverse
    end

    def to_a
      @results
    end

    private

    def check_argument(evaluation_results)
      TypeCheck.check evaluation_results, Array
      if evaluation_results.length.positive?
        TypeCheck.check evaluation_results.first, [EvaluationResult::Person, EvaluationResult::Org]
      end
    end
  end
end
