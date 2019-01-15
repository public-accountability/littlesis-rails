# frozen_string_literal: true

class OligrapherGraphData
  attr_reader :hash
  delegate_missing_to :@hash

  def initialize(str_or_hash_or_nil = nil)
    case str_or_hash_or_nil
    when nil
      @hash = {}
    when String
      @hash = JSON.parse(str_or_hash_or_nil)
    when Hash
      @hash = str_or_hash_or_nil
    else
      raise TypeError, 'OligrapherGraphData only accepts these types: String, Hash, Nil'
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

  def image_fixer
    OligrapherGraphDataImageFixer.new(self)
  end

  def self.load(obj)
    TypeCheck.check obj, [String, Hash, OligrapherGraphData], allow_nil: true

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
