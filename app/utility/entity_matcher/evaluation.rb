# frozen_string_literal: true

module EntityMatcher
  # Evaluatutes two instances of +TestCase+
  class Evaluation
    # call with two instances of EntityMatcher::TestCase::Person
    # +match+ is required to be assoicated with an +Entity+
    #
    # .result returns an instance of  `EvaluationResult`
    class Base
      attr_reader :result, :test_case, :match

      def initialize(test_case, match)
        validate_arguments test_case, match
        @test_case = test_case
        @match = match
        # Retrives either EvaluationResult::Person or EvaluationResult::Org
        @result = EvaluationResult.const_get(self.class.name.demodulize).new
        @result.entity = @match.entity
        comparisons
      end

      protected

      def comparisons
        raise NotImplementedError
      end

      # symbol --> nil | true | false
      def compare_field(field)
        return nil if @test_case.public_send(field).nil? || @match.public_send(field).nil?
        @test_case.public_send(field) == @match.public_send(field)
      end

      def blurb_keyword
        return nil if @test_case.keywords.blank?
        return false if @match.entity.blurb.blank? && @match.entity.summary.blank?

        test_keywords = "#{@match.entity.blurb} #{@match.entity.summary}"
                          .downcase
                          .gsub(/[[:punct:]]/, '')
                          .split(' ')
                          .to_set

        @test_case.keywords.each do |keyword|
          return true if test_keywords.include? keyword.downcase
        end

        return false
      end

      def common_relationship
        return nil if @test_case.associated_entities.blank?
        @common_relationship = (@test_case.associated_entities.to_set & @match.associated_entities.to_set).present?
      end

      private

      def validate_arguments(test_case, match)
        TypeCheck.check test_case, EntityMatcher::TestCase.const_get(self.class.name.demodulize)
        TypeCheck.check match, EntityMatcher::TestCase.const_get(self.class.name.demodulize)
        TypeCheck.check match.entity, Entity
      end
    end

    ##
    # Evaluates two People
    #
    class Person < Base
      private

      def comparisons
        @result.same_last_name = compare_field(:last)
        @result.same_first_name = compare_field(:first)
        @result.same_middle_name = compare_field(:middle)
        @result.same_prefix = compare_field(:prefix)
        @result.same_suffix = compare_field(:suffix)
        @result.mismatched_suffix = mismatched_suffix
        @result.similar_first_name = similar_first_name
        @result.similar_last_name = similar_last_name
        @result.common_relationship = common_relationship
        @result.blurb_keyword = blurb_keyword
        @result.common_last_name = CommonName.includes?(@match.fetch('name_last'))
      end

      def similar_first_name
        NameSimilarity
          .similar?(@test_case.fetch('name_first'), @match.fetch('name_first'), first_name: true)
      end

      def similar_last_name
        NameSimilarity
          .similar?(@test_case.fetch('name_last'), @match.fetch('name_last'))
      end

      def mismatched_suffix
        [@test_case.suffix.present?, @match.suffix.present?].select { |x| x == true }.length == 1
      end
    end

    ##
    # Evaluates two Orgs
    #
    class Org < Base
      private

      def comparisons
        @result.same_name = (@test_case.name.clean == @match.name.clean)
        @result.similar_name = NameSimilarity.similar?(@test_case.name.clean, @match.name.clean)
        @result.same_root = (@test_case.name.root == @match.name.root)
        @result.similar_root = NameSimilarity.similar?(@test_case.name.root, @match.name.root)
        @result.matches_alias = matches_alias
        @result.common_relationship = common_relationship
        @result.blurb_keyword = blurb_keyword
      end

      def matches_alias
        aliases = @match.entity.also_known_as.map { |n| OrgName.parse(n).clean }
        return nil if aliases.empty?
        aliases.each do |a|
          return true if a == @test_case.name.clean
        end
        return false
      end
    end
  end
end
