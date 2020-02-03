# frozen_string_literal: true

class NameSimilarity
  Comparisons = Struct.new(:string_similar,
                           :same_first_name,
                           :similar_first_name,
                           :same_last_name,
                           :similar_last_name,
                           :same_middle_name)

  class Person
    extend Forwardable
    attr_reader :comparisons
    def_delegators :@comparisons, :to_h, :[]

    def initialize(a, b)
      @a = NameParser.new(a).validate!
      @b = NameParser.new(b).validate!
      @comparisons = Comparisons.new

      @comparisons.string_similar = StringSimilarity.similar?(@a.raw, @b.raw)
      @comparisons.same_first_name = @a.first == @b.first
      @comparisons.similar_first_name = ::Person.same_first_names(@a.first).include?(@b.first) ||
                                        ::Person.same_first_names(@b.first).include?(@a.first) ||
                                        StringSimilarity.similar?(@a.first, @b.first)
      @comparisons.same_last_name = @a.last == @b.last
      @comparisons.similar_last_name = StringSimilarity.similar?(@a.last, @b.last)
      @comparisons.same_middle_name = @a.middle == @b.middle if @a.middle.present? && @b.middle.present?
    end

    def similar?
      return true if @comparisons.string_similar

      (@comparisons.same_first_name || @comparisons.similar_first_name) &&
        @comparisons.same_last_name
    end

    def self.similar?(a, b)
      new(a, b).similar?
    end
  end
end
