# frozen_string_literal: true

require_relative 'entity_matcher/query'
require_relative 'entity_matcher/search'
require_relative 'entity_matcher/evaluation_result'
require_relative 'entity_matcher/evaluation'

module EntityMatcher
  # String, kwargs --> Array[EvaluateResult]
  def self.find_matches_for_person(name, **kwargs)
    test_case = TestCase::Person.new(name, **kwargs)

    search_results = Search.by_name(test_case.last).map do |entity|
      EntityMatcher::Evaluation::Person.new(test_case, TestCase::Person.new(entity)).result
    end

    EvaluationResultSet.new search_results
  end

  # String, kwargs --> Array[EvaluateResult]
  def self.find_matches_for_org(name, **kwargs)
    test_case = TestCase::Org.new(name, **kwargs)

    search_results = Search.by_org(name).map do |entity|
      EntityMatcher::Evaluation::Org.new(test_case, TestCase::Org.new(entity)).result
    end

    EvaluationResultSet.new search_results
  end
end
