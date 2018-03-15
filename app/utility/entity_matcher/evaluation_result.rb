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
#    - similar_first_name
#    - similar_last_name
#  relationship:
#    - common_relationship
#  keywords:
#    - blurb_keyword
#
# == Ranking order for Person:

# Tier 1: Same last name and Similar or same first
#--------------
# same first and last name + highest equal (non-zero) count of prefix/suffix/middle
# same first and last name + common relationship
# same first and last name + blurb keyword
# similar first name and same last name + same_middle | same_suffix
# similar first name and same last name + common relationship
# same first and last name
# similar first name and same last name + highest equal count of prefix/suffix/middle
# similar first name and same last name + blurb keyword
# similar first name and same last name

# Tier 2: Same first and similar last
#--------------
# same first and similar last + highest equal count of prefix/suffix/middle
# same first and similar last + common relationship
# same first and similar last + blurb keyword
# same first and similar last

# Tier 3: Similar first and similar last
#--------------
# similar first and similar last + highest equal count of prefix/suffix/middlew
# similar first and similar last + common relationshipa
# similar first and similar last + blurb keyword
# similar first and similar last

# Tier 4: Same last
#--------------
# same last + highest equal count of prefix/suffix/middle
# same last + common relationship
# same last + blurb keyword

# Tier 5: Similar last
#--------------
# similar last + highest equal count of prefix/suffix/middle
# similar last + common relationship
# similar last + blurb keyword
# similar last
#
module EntityMatcher
  module EvaluationResult
    PERSON_ATTRS = [
      :same_last_name,
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
    ].freeze

    ORG_ATTRS = [
      :common_relationship,
      :blurb_keyword,
      :entity
    ].freeze

    Person = Struct.new(*PERSON_ATTRS) do
      include Comparable
      alias_method :same_first, :same_first_name
      alias_method :same_last, :same_last_name
      alias_method :similar_first, :similar_first_name
      alias_method :similar_last, :similar_last_name

      # ignore entity when testing for equality
      def eql?(other)
        self.to_h.except(:entity) == other.to_h.except(:entity)
      end

      def ==(other)
        self.eql? other.to_h
      end

      # This is sorted by placing better ranked matches "higher" (returning 1) However, this causes
      # the best matches to be placed at the END of the array as if sorted in ascending order.
      # +EvalutationResultSet+ reverses the array, but unexpected outcomes might happen
      # if you use an array of Person Structs directly instead of the ResultSet class
      def <=>(other)
        return 0 if self == other

        ##
        # These sort base on common tier criteria
        #

        # Tier 1
        return 1 if (self.same_last && self.same_or_similar_first_name) && !(other.same_last && other.same_or_similar_first_name)
        return -1 if !(self.same_last && self.same_or_similar_first_name) && (other.same_last && other.same_or_similar_first_name)
        # Tier 2
        return 1 if (self.same_first && self.similar_last) && !(other.same_first && other.similar_last)
        return -1 if !(self.same_first && self.similar_last) && (other.same_first && other.similar_last)
        # Tier 3
        return 1 if (self.similar_first && self.similar_last) && !(other.similar_first && other.similar_last)
        return -1 if !(self.similar_first && self.similar_last) && (other.similar_first && other.similar_last)
        # Tier 4
        return 1 if self.same_last && !other.same_last
        return -1 if !self.same_last && other.same_last
        # Tier 5
        return 1 if self.similar_last && !other.similar_last
        return -1 if !self.similar_last && other.similar_last

        ##
        # These sort the between each tier

        # tier 1
        # Same last name and same or similar first name
        if (self.same_last && self.same_or_similar_first_name) && (other.same_last && other.same_or_similar_first_name)
          return compare_same_last(other)
        end

        # tier 2
        # same first name and similar last name
        if (self.same_first && self.similar_last) && (other.same_first && other.similar_last)
          return compare_extras_or_equal(other)
        end

        # tier 3
        # similar first and similar last
        if (self.similar_first && self.similar_last) && (other.similar_first && other.similar_last)
          return compare_extras_or_equal(other)
        end

        # tier 4
        # same last name
        if self.same_last && other.same_last
          return compare_extras_or_equal(other)
        end

        # tier 5
        if self.similar_last && other.similar_last
          return compare_extras_or_equal(other)
        end

        return compare_attr(:common_relationship_and_blurb, other) if compare_attr(:common_relationship_and_blurb, other)
        return compare_attr(:common_relationship, other) if compare_attr(:common_relationship, other)
        return compare_attr(:blurb_keyword, other) if compare_attr(:blurb_keyword, other)
        return 0
      end

      # ASSUMES only called if both have same last name and the same or similar first name
      def compare_same_last(other)
        return compare_extras(other) if self.same_first && other.same_first && compare_extras(other)

        if (self.similar_first && self.same_last) && (other.similar_first && other.same_last)
          return 1 if (self.same_middle_name || self.same_suffix) && !(other.same_middle_name || other.same_suffix)
          return -1 if !(self.same_middle_name || self.same_suffix) && (other.same_middle_name || other.same_suffix)
          return 0 if (self.same_middle_name || self.same_suffix) && (other.same_middle_name || other.same_suffix)
          return compare_attr(:common_relationship, other) if compare_attr(:common_relationship, other)
        end

        return compare_attr(:same_first_last?, other) if compare_attr(:same_first_last?, other)
        compare_extras_or_equal(other)
      end

      # The same as compare_extras, except returning 0 intead of nil
      def compare_extras_or_equal(other)
        extras_comparsion_val = compare_extras(other)
        return extras_comparsion_val.nil? ? 0 : extras_comparsion_val
      end

      # Compares in order:
      # - highest non-zero values of same prefix, same suffix, and same middle
      # - presense of common relationship
      # - presense of keyword
      # returns 0, 1, -1 or nil
      def compare_extras(other)
        if self.same_middle_prefix_suffix_count.positive? || other.same_middle_prefix_suffix_count.positive?
          count_diff = self.same_middle_prefix_suffix_count - other.same_middle_prefix_suffix_count
          return 1 if count_diff.positive?
          return -1 if count_diff.negative?
          return compare_attr(:common_relationship_and_blurb, other) if compare_attr(:common_relationship_and_blurb, other)
          return compare_attr(:common_relationship, other) if compare_attr(:common_relationship, other)
          return compare_attr(:blurb_keyword, other) if compare_attr(:blurb_keyword, other)
          return 0
        end
        return compare_attr(:common_relationship_and_blurb, other) if compare_attr(:common_relationship_and_blurb, other)
        return compare_attr(:common_relationship, other) if compare_attr(:common_relationship, other)
        return compare_attr(:blurb_keyword, other) if compare_attr(:blurb_keyword, other)
      end

      # :category: helpers

      # count of positive values for three criteria: same_middle, sameprefix, and same_suffix
      def same_middle_prefix_suffix_count
        [same_middle_name, same_prefix, same_suffix].keep_if(&:present?).count
      end

      def same_first_last?
        same_last_name && same_first_name
      end

      def same_or_similar_first_name
        same_first_name || similar_first_name
      end

      def common_relationship_and_blurb
        common_relationship && blurb_keyword
      end

      private

      # returns 0 if both have the attribute
      # returns -1 if the other has it
      # returns 1 if self has it
      # returns nil if neither have the attribute
      def compare_attr(prop, other)
        return 0 if self.send(prop) && other.send(prop)
        return 1 if self.send(prop) && !other.send(prop)
        return -1 if !self.send(prop) && other.send(prop)
      end
    end

    Org = Struct.new(*ORG_ATTRS) do
      include Comparable
    end
  end
end
# rubocop:enable Style/RedundantSelf, Metrics/LineLength
# rubocop:enable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize
