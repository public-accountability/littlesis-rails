# frozen_string_literal: true

# Simple data class for results of matching evaluation
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
  class EvaluationResult
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
end
