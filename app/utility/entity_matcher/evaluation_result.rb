# frozen_string_literal: true

# rubocop:disable Style/RedundantSelf, Metrics/LineLength
# rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize
#
# Two data classes EvaluationResult:Person and EvaluationResult:Org
# to containg the results of matching evaluation
#
# Criteria for Person
#  name:
#    - same_last_name
#    - same_first_name
#    - same_middle_name
#    - same_prefix
#    - same_suffix
#    - mismatched_suffix
#    - mismatched_middle_name
#    - similar_first_name
#    - similar_last_name
#  relationship:
#    - common_relationship
#  keywords:
#    - blurb_keyword
#
# == Ranking order for Person:
#
#
# TODO:
#   - determine level for automatch
#   - check commonality of name
#   - check aliases
#   - devalue mismatched suffix?
#

# Tier 1: Same last name and same or similar first name
#-----------
# Tier 2: similar last name
#--------------
# Tier 3: Same last and similar last
#--------------
# Tier 4: only blurb keyword and/or simlar relationship
#--------------

# == critera for orgs
# - same_name
# - matches_alias
# - similar_name
# - same_root
# - similar_root
# - common_relationship
# - blurb_keyword

# == Ranking order for Org
# - same_name
# - matches_alias
# - same_root
# - similar_name
# - similar_root
#  common_relationship and common_blurb are evaluated within those categories
module EntityMatcher
  module EvaluationResult
    PERSON_ATTRS = [
      :same_last_name,
      :same_first_name,
      :same_middle_name,
      :same_prefix,
      :same_suffix,
      :mismatched_suffix,
      :different_middle_name,
      :mismatched_middle_name,
      :similar_last_name,
      :similar_first_name,
      :common_relationship,
      :blurb_keyword,
      :common_last_name
    ].freeze

    ORG_ATTRS = [
      :same_name,
      :similar_name,
      :same_root,
      :similar_root,
      :matches_alias,
      :common_relationship,
      :blurb_keyword
    ].freeze

    class Base
      attr_accessor :entity
      include Comparable

      # Determines if the current match has enough critera to be automatched
      def automatch?
        raise NotImplementedError
      end

      # by comparinng #values, we can ignore the attributes, entity, when testing for equality
      def eql?(other)
        (self.class == other.class) && (self.values == other.values)
      end

      def ==(other)
        self.eql? other
      end

      # Returns a Set of symbols
      # The subclass must define the constant CRITERIA
      def values
        return @_values if defined?(@_values)
        @_values = self.class.const_get(:CRITERIA).dup.keep_if { |attr| self.send(attr) }.to_set
      end

      # Returns relative ranking of where the values line in up
      # according to the critia established by the constant RANKING
      #
      # The lower the integer the better the match.
      # If no match in found in the rankings array it returns
      # the the value of one more than the last item in the array
      #
      # Set#superset? is used instead of #== because
      # there are same critea that are not used in the ranking sets that can be ignored.
      def ranking
        idx = self.class.const_get(:RANKINGS).find_index { |s| values.superset?(s) }
        return self.class.const_get(:RANKINGS).length if idx.nil?
        idx
      end

      def as_json(*)
        {
          'entity' => entity&.as_json(except: %w[notes delta last_user_id]),
          'values' => values.to_a,
          'ranking' => ranking,
          'automatch' => automatch?
        }
      end
    end

    class Person < Base
      attr_accessor(*PERSON_ATTRS)
      CRITERIA = PERSON_ATTRS

      NAME_EXTRAS = [
        Set[:same_middle_name, :same_prefix, :same_suffix],
        Set[:same_middle_name, :same_suffix],
        Set[:same_middle_name, :same_prefix],
        Set[:same_middle_name],
        Set[:same_suffix, :same_prefix],
        Set[:same_suffix],
        Set[:same_prefix],
        Set.new
      ].freeze

      # *Symbols -> Array[Set]
      private_class_method def self.compute_name_sets(*symbols)
        NAME_EXTRAS.map { |set_of_name_extras| (Set.new(symbols) + set_of_name_extras).freeze }
      end

      # Same last name + same or similar first name
      TIER1 = [
        compute_name_sets(:same_last_name, :same_first_name, :common_relationship, :blurb_keyword),
        compute_name_sets(:same_last_name, :same_first_name, :common_relationship),

        compute_name_sets(:same_last_name, :similar_first_name, :common_relationship, :blurb_keyword),
        compute_name_sets(:same_last_name, :similar_first_name, :common_relationship),

        compute_name_sets(:same_last_name, :same_first_name, :blurb_keyword),
        compute_name_sets(:same_last_name, :similar_first_name, :blurb_keyword),
        compute_name_sets(:same_last_name, :same_first_name),
        compute_name_sets(:same_last_name, :similar_first_name)
      ].flatten.freeze

      # Similar last name + same or similar first name
      TIER2 = [
        compute_name_sets(:similar_last_name, :same_first_name, :common_relationship, :blurb_keyword),
        compute_name_sets(:similar_last_name, :same_first_name, :common_relationship),
        compute_name_sets(:similar_last_name, :same_first_name, :blurb_keyword),
        compute_name_sets(:similar_last_name, :same_first_name),
        compute_name_sets(:similar_last_name, :similar_first_name, :common_relationship, :blurb_keyword),
        compute_name_sets(:similar_last_name, :similar_first_name, :common_relationship),
        compute_name_sets(:similar_last_name, :similar_first_name, :blurb_keyword),
        compute_name_sets(:similar_last_name, :similar_first_name)
      ].flatten.freeze

      # same or simialr last with no matching first name
      TIER3 = [
        compute_name_sets(:same_last_name, :common_relationship, :blurb_keyword),
        compute_name_sets(:same_last_name, :common_relationship),
        compute_name_sets(:same_last_name, :blurb_keyword),
        compute_name_sets(:same_last_name),
        compute_name_sets(:similar_last_name, :common_relationship, :blurb_keyword),
        compute_name_sets(:similar_last_name, :common_relationship),
        compute_name_sets(:similar_last_name, :blurb_keyword),
        compute_name_sets(:similar_last_name)
      ].flatten.freeze

      # no same or similar last or first names. only common relationship and blurb keyword
      TIER4 = [
        Set[:common_relationship, :blurb_keyword],
        Set[:common_relationship],
        Set[:blurb_keyword]
      ].freeze

      RANKINGS = (TIER1 + TIER2 + TIER3 + TIER4).freeze

      AUTOMATCH_MINIMUM_SET = Set[:same_last_name, :similar_first_name, :common_relationship].freeze
      AUTOMATCH_MINIMUM_RANK = RANKINGS.rindex { |s| s == AUTOMATCH_MINIMUM_SET }

      # same_last_name, :similar_first_name, :common_relationship
      # Lower values are "better" matchers here
      def <=>(other)
        ##
        # Sort based on common tier criteria
        # This isn't strickly necessary since comparing ranking will correctly sort.
        # There **might* be a performance benefit to this, but that's not fully confirmed.
        #
        # Tier One
        return -1 if self.tier_one? && !other.tier_one?
        return 1 if !self.tier_one? && other.tier_one?
        # Tier Two
        return -1 if self.tier_two? && !other.tier_two?
        return 1 if !self.tier_two? && other.tier_two?
        # Tier Three
        return -1 if self.tier_three? && !other.tier_three?
        return 1 if !self.tier_three? && other.tier_three?

        # return 0 if self == other
        self.ranking <=> other.ranking
      end

      def automatch?
        return true if ranking <= AUTOMATCH_MINIMUM_RANK
        # The match has the exact same first and last name
        # and the last name is uncommon, it can also be automatched
        if same_last_name && same_first_name && (common_last_name == false) && !mismatched_suffix && !mismatched_middle_name
          return true
        else
          return false
        end
      end

      def tier_one?
        same_last_name && same_or_similar_first_name
      end

      def tier_two?
        similar_last_name && same_or_similar_first_name
      end

      def tier_three?
        (same_last_name || similar_last_name) && !same_or_similar_first_name
      end

      private

      def same_or_similar_first_name
        same_first_name || similar_first_name
      end
    end

    class Org < Base
      attr_accessor(*ORG_ATTRS)
      CRITERIA = ORG_ATTRS

      # *Symbols -> Array[Set]
      private_class_method def self.compute_variations(*symbols)
        [
          Set[:common_relationship, :blurb_keyword],
          Set[:common_relationship],
          Set[:blurb_keyword]
        ].map { |s| (Set.new(symbols) + s).freeze }
      end

      RANKINGS = [
        compute_variations(:same_name),
        compute_variations(:matches_alias),
        Set[:same_name],
        Set[:matches_alias],
        compute_variations(:similar_name),
        compute_variations(:same_root),
        compute_variations(:similar_root),
        Set[:similar_name],
        Set[:same_root],
        Set[:similar_root]
      ].flatten.freeze

      AUTOMATCH_MINIMUM_SET = Set[:matches_alias].freeze
      AUTOMATCH_MINIMUM_RANK = RANKINGS.rindex { |s| s == AUTOMATCH_MINIMUM_SET }

      def <=>(other)
        self.ranking <=> other.ranking
      end

      def automatch?
        ranking <= AUTOMATCH_MINIMUM_RANK
      end
    end
  end
end
# rubocop:enable Style/RedundantSelf, Metrics/LineLength
# rubocop:enable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize
