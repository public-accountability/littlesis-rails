# frozen_string_literal: true

class NameSimilarity
  Comparisons = Struct.new(:string_similar,
                           :same_first_name,
                           :similar_first_name,
                           :same_last_name,
                           :similar_last_name,
                           :same_middle_name)

  class Person
    attr_reader :comparisons

    extend Forwardable

    def_delegators :@comparisons, :to_h, :[]

    def initialize(a, b)
      @a = NameParser.new(a).validate!
      @b = NameParser.new(b).validate!
      @comparisons = Comparisons.new

      @comparisons.string_similar = StringSimilarity.similar?(@a.raw, @b.raw)
      @comparisons.same_first_name = @a.first == b.first
      @comparisons.similar_first_name = ::Person.same_first_names(@a.first).include?(@b.first) ||
                                        ::Person.same_first_names(@b.first).include?(@a.first) ||
                                        StringSimilarity.similar?(@a.first, @b.first)
      @comparisons.same_last_name = @a.last == b.last
      @comparisons.similar_last_name = StringSimilarity.similar?(@a.last, @b.last)
      @comparsion.same_middle_name = @a.middle == @b.middle if @a.middle.present? && @b.middle.present?
      # @comparsion.similar_middle_name = @a.middle == @b.middle if @a.middle.present? && @b.middle.present?
    end
  end
end
