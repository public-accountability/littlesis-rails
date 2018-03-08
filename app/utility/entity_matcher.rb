# frozen_string_literal: true

require_relative 'entity_matcher/query'
require_relative 'entity_matcher/search'
require_relative 'entity_matcher/evaluation_result'
require_relative 'entity_matcher/evaluation'

module EntityMatcher
  def self.find_matches(name, **kwargs)
    test_case = TestCase::Person.new(name, **kwargs)

    Search.by_name(test_case.last).map do |entity|
      potential_match = TestCase::Person.new(entity)
      evaluate(test_case, potential_match)
    end
  end

  # TestCase::Person, TestCase::Person ---> EvaluationResult
  def self.evaluate(*args)
    EntityMatcher::Evaluation.new(*args).result
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
