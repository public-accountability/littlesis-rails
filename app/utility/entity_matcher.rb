# frozen_string_literal: true

require_relative 'entity_matcher/query'
require_relative 'entity_matcher/search'
require_relative 'entity_matcher/evaluation_result'
require_relative 'entity_matcher/evaluation'

module EntityMatcher
  # String, kwargs --> Array[EvaluateResult]
  def self.find_matches_for_person(name, **kwargs)
    test_case = TestCase::Person.new(name, **kwargs)

    EvaluationResultSet.new(
      Search.by_name(test_case.last).map do |entity|
        potential_match = TestCase::Person.new(entity)
        evaluate_people(test_case, potential_match)
      end
    ).to_a
  end

  # String, kwargs --> Array[EvaluateResult]
  def self.find_matches_for_org(name, **kwargs)
    test_case = TestCase::Org.new(name, **kwargs)

    EvaluationResultSet.new(
      Search.by_org(name).map do |entity|
        potential_match = TestCase::Org.new(entity)
        evaluate_orgs(test_case, potential_match)
      end
    ).to_a
  end

  def self.evaluate_people(test_case, match)
    EntityMatcher::Evaluation::Person.new(test_case, match).result
  end

  def self.evaluate_orgs(test_case, match)
    EntityMatcher::Evaluation::Org.new(test_case, match).result
  end

  # +by_person_name+, +by_full_name+ and +by_org_name+
  # are legacy methods used in ForbesFourHundredImporter and EntityNameAddressCsvImporter,
  # which themselves are outdated import code that needs to be re-written.
  # Once those classes are removed or refactored, they can be removed from this class.

  def self.by_person_name
    raise NotImplementedError
  end

  def self.by_full_name
    raise NotImplementedError
  end

  def self.by_org_name
    raise NotImplementedError
  end
end
