# frozen_string_literal: true

class OligrapherGraphData
  attr_reader :hash
  delegate_missing_to :@hash

  def initialize(input = nil)
    case input
    when nil
      @hash = ActiveSupport::HashWithIndifferentAccess.new
    when String
      @hash = JSON.parse(input).with_indifferent_access
    when Hash, ActiveSupport::HashWithIndifferentAccess
      @hash = input.with_indifferent_access
    else
      raise TypeError, 'Accepted types: String, Hash, Nil'
    end
    freeze
  end

  def dump
    JSON.dump(@hash)
  end

  alias to_json dump

  def ==(other)
    other.instance_of?(self.class) && @hash == other.hash
  end

  alias eql? ==

  def self.load(obj)
    TypeCheck.check obj,
                    [String, Hash, ActiveSupport::HashWithIndifferentAccess, OligrapherGraphData],
                    allow_nil: true

    obj.is_a?(OligrapherGraphData) ? obj : new(obj)
  end

  class Type < ActiveRecord::Type::Json
    def deserialize(value)
      OligrapherGraphData.load super(value)
    end

    def serialize(value)
      super(OligrapherGraphData.load(value).hash)
    end
  end
end
