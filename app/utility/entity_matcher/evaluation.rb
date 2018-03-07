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
      comparisons
    end

    private

    def comparisons
      @result.same_last_name = compare_field(:last)
      @result.same_first_name = compare_field(:first)
      @result.same_prefix = compare_field(:prefix)
      @result.same_middle = compare_field(:prefix)
      @result.same_suffix = compare_field(:suffix)
      @result.mismatched_suffix = mismatched_suffix
      @result.similar_first_name = similar_first_name
      @result.similar_last_name = similar_last_name
      @result.common_relationship = common_relationship
      @result.blurb_keyword = blurb_keyword
    end

    def blurb_keyword
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

    def mismatched_suffix
      [@test_case.suffix.present?, @match.suffix.present?].select { |x| x == true }.length == 1
    end

    # symbol --> nil | true | false
    def compare_field(field)
      return nil if @test_case.public_send(field).nil? || @match.public_send(field).nil?
      @test_case.public_send(field) == @match.public_send(field)
    end

    def validate_arguments(test_case, match)
      TypeCheck.check test_case, EntityMatcher::TestCase::Person
      TypeCheck.check match, EntityMatcher::TestCase::Person
      TypeCheck.check match.entity, Entity
    end
  end
end
