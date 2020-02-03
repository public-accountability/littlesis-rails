# frozen_string_literal: true

# All string are handled case-insensitively
class StringSimilarity
  include TypeCheck
  attr_reader :similar,
              :equal,
              :levenshtein

  MAX_LEVENSHTEIN_VALUE = 2

  def self.compare(a, b)
    new(a, b)
  end

  def self.similar?(a, b)
    new(a, b).similar
  end

  def initialize(a, b)
    type_check a, String
    type_check b, String
    @a = a.upcase
    @b = b.upcase
    @similar = false

    equal_test
    levenshtein_test
  end

  private

  def equal_test
    @equal = (@a == @b)
    @similar = true if @equal
  end

  def levenshtein_test
    @levenshtein = Text::Levenshtein.distance(@a, @b)
    @similar = true if @levenshtein <= MAX_LEVENSHTEIN_VALUE
  end
end
