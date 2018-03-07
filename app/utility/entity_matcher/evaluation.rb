# frozen_string_literal: true
module EntityMatcher

  # EntityMatcher::TestCase::Person ---> EntityMatcher::EvaluationResult
  def self.evaluate(*args)
    EntityMatcher::Evaluation.new(*args).result
  end

  # Evaluations two instances +TestCase+
  # 
  class Evaluation
    attr_reader :result, :test_case, :match

    # call with two instances of EntityMatcher::TestCase::Person
    # +match+ is required to be assoicated with an +Entity+
    #
    # .result returns an instance of  `EvaluationResult`
    def initialize(test_case, match)
      validate_arguments(test_case, match)

      @test_case = test_case
      @match = match
      @result = EvaluationResult.new

      comparisons.each do |(criteria, evaluation)|
        @result.public_send "#{criteria}=", evaluation.call
      end
    end

    private

    # nested array containing the result field name
    # and a lambda that returns the value for that field
    def comparisons
      [
        [:same_last_name, -> { compare_field :last }],
        [:same_first_name, -> { compare_field :first }],
        [:same_prefix, -> { compare_field :prefix }],
        [:same_middle, -> { compare_field :prefix }],
        [:same_suffix, -> { compare_field :suffix }],
        [:mismatched_suffix, -> { @test_case.suffix.present? || @match.suffix.present? }],
        [:similar_first_name, -> { similar_first_name }],
        [:similar_last_name, -> { similar_last_name }],
        [:common_relationship, -> { common_relationship }]
      ]
    end

    def common_relationship
      return nil if @test_case.associated_entities.blank?
      @common_relationship = (@test_case.associated_entities.to_set & @match.associated_entities.to_set).present?
    end

    def similar_first_name
      NameSimilarity
        .similar?(@test_case.fetch('name_first'), @match.fetch('name_first'), first_name: true)
    end
    
    def similar_last_name
      NameSimilarity
        .similar?(@test_case.fetch('name_last'), @match.fetch('name_last'))
    end

    # symbol --> nil | true | false
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
end
