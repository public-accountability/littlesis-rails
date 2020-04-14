# frozen_string_literal: true

require_relative 'entity_matcher/query'
require_relative 'entity_matcher/search'
require_relative 'entity_matcher/evaluation_result'
require_relative 'entity_matcher/evaluation'

module EntityMatcher
  # String | Entity, kwargs --> Array[EvaluateResult]
  def self.find_matches_for_person(name, **kwargs)
    test_case = TestCase.person(name, **kwargs)

    if test_case.entity.present?
      search_results = Search.by_entity(test_case.entity)
    else
      search_results = Search.by_person_hash(test_case.name)
    end

    EvaluationResultSet.new(search_results.map do |entity|
      EntityMatcher::Evaluation::Person.new(test_case, TestCase.person(entity)).result
    end)
  end

  # String, kwargs --> Array[EvaluateResult]
  def self.find_matches_for_org(name, **kwargs)
    test_case = TestCase.org(name, **kwargs)

    search_results = Search.by_org(name).map do |entity|
      EntityMatcher::Evaluation::Org.new(test_case, TestCase.org(entity)).result
    end

    EvaluationResultSet.new search_results
  end
end
