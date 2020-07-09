# frozen_string_literal: true

class MathCaptcha
  RANGE = (0..20).freeze

  attr_reader :number_one, :number_two, :operation

  def initialize
    @number_one = rand(RANGE)
    @number_two = rand(RANGE)
    @operation = %i[+ -].sample
    freeze
  end

  def question
    [@number_one, @operation, @number_two].join(' ')
  end

  def self.correct?(number_one:, number_two:, operation:, answer:)
    number_one.to_i.public_send(operation, number_two.to_i).eql?(answer.to_i)
  end
end
