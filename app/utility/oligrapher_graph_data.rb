# frozen_string_literal: true

class OligrapherGraphData
  attr_reader :hash

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

  def ==(other)
    other.instance_of?(self.class) && @hash == other.hash
  end

  alias eql? ==

  class SerializationTypeMismatch < ActiveRecord::SerializationTypeMismatch; end

  def self.dump(obj)
    raise SerializationTypeMismatch unless obj.nil? || obj.is_a?(OligrapherGraphData)

    return if obj.nil? || obj.hash.blank?

    JSON.dump(obj.hash)
  end

  def self.load(obj)
    TypeCheck.check obj, [String, Hash], allow_nil: true

    obj.nil? ? new(nil) : new(obj)
  end
end
