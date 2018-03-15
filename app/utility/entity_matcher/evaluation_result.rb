# frozen_string_literal: true

# rubocop:disable Style/RedundantSelf
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

# SAME LAST NAME and Similar or same first
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

# Same first and similar last
#--------------
# same first and similar last + highest equal count of prefix/suffix/middle
# same first and similar last + common relationship
# same first and similar last + blurb keyword
# same first and similar last

# Similar first and similar last
#--------------
# similar first and similar last + highest equal count of prefix/suffix/middlew
# similar first and similar last + common relationshipa
# similar first and similar last + blurb keyword
# similar first and similar last

# Same last
#--------------
# same last + highest equal count of prefix/suffix/middle
# same last + common relationship
# same last + blurb keyword

# similar last
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

      # I'm not 100% sure why but the default struct equality does not work as expected.
      # It might have to do with how it comparses subclasses?...anyways, not worth the time right now.
      # eql? does what we want [ziggy Thu 15 Mar 2018]
      def ==(other)
        self.eql? other.to_h
      end

      # This is sorted by ranking "higher" matches higher (returning 1)
      # However causes the best matches to be placed at the END of the array
      # EvalutationResultSet reverses the array, but unexpected outcomes might happen
      # if you use an array directly instead of the ResultSet oject
      def <=>(other)
        return 0 if self == other

        return 1 if self.same_last && !other.same_last
        return -1 if !self.same_last && other.same_last

        return 1 if self.same_first && !other.same_first
        return -1 if !self.same_first && other.same_first

        # tier 1
        # Same last name and same or similar first name
        if (self.same_last && other.same_last) && (self.same_or_similar_first_name && other.same_or_similar_first_name)
          return compare_same_last(other)
        end

        if (self.same_first_name && self.similar_last_name) && (other.same_first_name && other.similar_last_name)
          return compare_extras_or_equal(other)
        end

        return 0
      end

      # ASSUMES only called if both have same last name and the same or similar first name
      def compare_same_last(other)
        return compare_extras(other) if self.same_first && other.same_first && compare_extras(other)

        if self.similar_first_name && other.similar_first_name
          return 1 if (self.same_middle_name || self.same_suffix) && !(other.same_middle_name || other.same_suffix)
          return -1 if !(self.same_middle_name || self.same_suffix) && (other.same_middle_name || other.same_suffix)
          return 0 if (self.same_middle_name || self.same_suffix) && (other.same_middle_name || other.same_suffix)
          return compare_attr(:common_relationship, other) if compare_attr(:common_relationship, other)
        end

        return compare_attr(:same_first_last?, other) if compare_attr(:same_first_last?, other)
        compare_extras_or_equal(other)
      end

      # The same as compare_extras, except it return 0 intead of nil
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
        if self.extra_name_c.positive? || other.extra_name_c.positive?
          count_diff = self.extra_name_c - other.extra_name_c
          return 1 if count_diff.positive?
          return -1 if count_diff.negative?
          return compare_attr(:common_relationship, other) if compare_attr(:common_relationship, other)
          return compare_attr(:blurb_keyword, other) if compare_attr(:blurb_keyword, other)
          return 0
        end
        return compare_attr(:common_relationship, other) if compare_attr(:common_relationship, other)
        return compare_attr(:blurb_keyword, other) if compare_attr(:blurb_keyword, other)
      end

      # count of positive values for three criteria: same_middle, smae_prefix, and same_suffix
      def same_middle_prefix_suffix_count
        [same_middle_name, same_prefix, same_suffix].keep_if(&:present?).count
      end
      alias_method :extra_name_c, :same_middle_prefix_suffix_count

      # are the first and last name the same
      def same_first_last?
        same_last_name && same_first_name
      end

      def same_or_similar_first_name
        same_first_name || similar_first_name
      end

      private

      # returns 0 if both have the attribute
      # returns -1 if the other has it
      # returns 1 if self has it

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
# rubocop:enable Style/RedundantSelf
