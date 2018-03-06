# frozen_string_literal: true

module EntityMatcher
  class ResultSet
    def initialize(test_case, matches)
    end
  end

  # Compares the test_case to the match
  class Evaluation
    attr_reader :result, :test_case, :match

    def initialize(test_case, match)
      validate_arguments(test_case, match)

      @test_case = test_case
      @match = match
      @result = EvaluationResult.new
      compare
    end

    def compare
      [
        [:same_last_name, -> { compare_field :last }],
        [:same_first_name, -> { compare_field :first }],
        [:same_prefix, -> { compare_field :prefix }]
      ].each do |(criteria, score)|
        @result.public_send "#{criteria}=", score.call
      end
    end

    private

    def compare_field(field)
      return nil if @test_case.public_send(field).nil? || @match.public_send(field).nil?
      @test_case.public_send(field) == @match.public_send(field)
    end

    def validate_arguments(test_case, match)
      raise ArgumentError unless test_case.is_a? EntityMatcher::TestCase::Person
      raise ArgumentError unless match.is_a? EntityMatcher::TestCase::Person
      raise ArgumentError unless match.entity.is_a? Entity
    end
  end

  # Critia:
  #  name:
  #    - same_last_name
  #    - similar_last_name
  #    - same_first_name
  #    - similar_first_name
  #    - same_prefix
  #    - same_suffix
  #    - same_middle
  #  keywords:
  #    - keyword_found_in_blurb
  #  relationship:
  #    - relationship_in_common

  class EvaluationResult
    attr_accessor :same_last_name,
                  :similar_last_name,
                  :same_first_name,
                  :similar_first_name,
                  :same_prefix
  end

    
end
