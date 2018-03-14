# frozen_string_literal: true

# Two data classes EvaluationResult:Person and EvaluationResult:Org
# to containg the results of matching evaluation
# Criteria
#  name:
#    - same_last_name
#    - same_first_name
#    - same_middle_name
#    - same_prefix
#    - same_suffix
#    - mismatched_suffix
#    - similar_first_name
#    - similar_last_name
#  relationship:
#    - common_relationship
#  keywords:
#    - blurb_keyword

module EntityMatcher
  module EvaluationResult
    class Person
      attr_accessor :same_last_name,
                    :same_first_name,
                    :same_middle_name,
                    :same_prefix,
                    :same_suffix,
                    :mismatched_suffix,
                    :similar_last_name,
                    :similar_first_name,
                    :common_relationship,
                    :blurb_keyword,
                    :entity
    end

    class Org
      attr_accessor :common_relationship,
                    :blurb_keyword,
                    :entity
    end
  end
end
