# frozen_string_literal: true

class UserAbilities
  ALL_ABILITIES = %I[admin edit delete merge bulk match].to_set.freeze

  extend Forwardable
  attr_reader :abilities
  def_delegators :@abilities, :empty?, :to_a

  def initialize(*args)
    Set.new
    @abilities = args.to_set.freeze
    assert_valid_set(@abilities)
    freeze
  end

  # Object Serialization #

  def self.dump(obj)
    raise ActiveRecord::SerializationTypeMismatch unless obj.nil? || obj.is_a?(UserAbilities)

    return if obj.blank?

    obj.to_a.join(',')
  end

  def self.load(obj)
    TypeCheck.check obj, String, allow_nil: true

    return new if obj.nil?

    new(*obj.split(',').map(&:to_sym))
  end

  class InvalidUserAbilitiesSetError < StandardError; end

  private

  def assert_valid_set(set)
    unless set.is_a?(Set) && set.subset?(ALL_ABILITIES)
      raise InvalidUserAbilitiesSetError
    end
  end
end
