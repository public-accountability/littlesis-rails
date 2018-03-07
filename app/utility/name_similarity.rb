# frozen_string_literal: true

# A class to compare names using a variety of metrics.
#
# All string are handled case-insensitively
class NameSimilarity
  include TypeCheck
  attr_reader :similar,
              :equal,
              :levenshtein,
              :first_name_alias
  
  MAX_LEVENSHTEIN_VALUE = 2

  def initialize(a, b, first_name: false)
    type_check a, String
    type_check b, String
    @a = a.upcase
    @b = b.upcase
    
    run { equal_test }
    run { levenshtein_test }
    run { first_name_test } if first_name

    # set similar to false if it hasn't changed in the tests
    @similar = false if @similar.nil?
  end

  def equal_test
    @equal = (@a == @b)
    is_similar if @equal
  end

  def levenshtein_test
    @levenshtein = Text::Levenshtein.distance(@a, @b)
    is_similar if @levenshtein <= MAX_LEVENSHTEIN_VALUE
  end

  def first_name_test
    if Person.same_first_names(@a).include?(@b.downcase) || Person.same_first_names(@b).include?(@a.downcase)
      @first_name_alias = true
      is_similar
    end
  end

  private

  def run
    yield unless similar
  end

  def is_similar
    @similar = true
  end

  def self.compare(a,b)
    new(a,b)
  end
end
