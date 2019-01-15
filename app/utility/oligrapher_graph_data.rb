# frozen_string_literal: true

class OligrapherGraphData
  attr_reader :hash
  delegate_missing_to :@hash

  def initialize(str_or_hash_or_nil = nil)
    case str_or_hash_or_nil
    when nil
      @hash = ActiveSupport::HashWithIndifferentAccess.new
    when String
      @hash = ActiveSupport::HashWithIndifferentAccess.new(JSON.parse(str_or_hash_or_nil))
    when Hash, ActiveSupport::HashWithIndifferentAccess
      @hash = ActiveSupport::HashWithIndifferentAccess.new(str_or_hash_or_nil)
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

  # returns new OligrapherGraphData with updated images
  def refresh_images
    image_fixer = OligrapherGraphDataImageFixer.new(self)
    image_fixer.changed? ? image_fixer.oligrapher_graph_data : self
  end

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
