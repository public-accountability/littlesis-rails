# frozen_string_literal: true

module EntityMatcher
  def self.find_matches_for_person(name, **kwargs)
    test_case = TestCase.person(name, **kwargs)

    if test_case.entity.present?
      search_results = Search
                         .by_entity(test_case.entity)
                         .evaluate_with(test_case)
    else
      search_results = Search
                         .by_person_hash(test_case.name)
                         .evaluate_with(test_case)
    end

    EvaluationResultSet.new(search_results)
  end

  def self.find_matches_for_org(name, **kwargs)
    test_case = TestCase.org(name, **kwargs)

    search_results = Search
                       .by_org_name(name)
                       .evaluate_with(test_case)

    EvaluationResultSet.new(search_results)
  end
end
