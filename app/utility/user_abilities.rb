# frozen_string_literal: true

# This class is used by the column "abilities" on User.
# It holds the abilities (formally known as permissions) that the user can do.
# It's a wrapper around a `Set`.
#
# There are currently 6 abilities (plus admin)
#
#    edit -> basic editing opertions. All users have this by default
#    delete -> ability to delete entities, relationships, and lists
#    merge -> ability to merge entities together
#    bulk -> ability to bulk add unlmited entities, relationships, and lists
#    match -> ability to use the match donors tools
#    list  -> ability to add/remove entitie from open lists
#
# Admins can do all of those plus use any admin-only features
#
class UserAbilities
  ALL_ABILITIES = %I[admin edit delete merge bulk match list].to_set.freeze

  extend Forwardable
  attr_reader :abilities
  def_delegators :@abilities, :empty?, :blank?, :to_a, :include?

  def initialize(*args)
    @abilities = args.to_set.freeze
    assert_valid_set(@abilities)
    freeze
  end

  def eql?(other)
    TypeCheck.check other, UserAbilities

    @abilities.eql?(other.abilities)
  end

  def to_set
    @abilities.dup
  end

  {
    :admin => :admin?,
    :edit => :editor?,
    :delete => :deleter?,
    :merge => :merger?,
    :bulk => :bulker?,
    :match => :matcher?,
    :list => :lister?
  }.each do |(ability, method)|
    define_method(method) do
      include?(ability) || include?(:admin)
    end
  end

  # String|Symbol, ... --> UserAbilities
  # Creates two modification functions: #add and #remove
  # These are "functional". They return new instances of UserAbilities
  [[:add, :merge], [:remove, :difference]].each do |(method_name, set_operation)|
    define_method(method_name) do |*args|
      assert_valid_abilities(args)

      UserAbilities.new(*@abilities.dup.public_send(set_operation, args.map(&:to_sym)))
    end
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
  class InvalidUserAbilityError < StandardError; end

  private

  def assert_valid_abilities(values)
    values.each { |value| assert_valid_ability(value) }
  end

  def assert_valid_ability(value)
    unless ALL_ABILITIES.include?(value.to_sym)
      raise InvalidUserAbilityError, "#{value} is not a valid user ability"
    end
  end

  def assert_valid_set(set)
    unless set.is_a?(Set) && set.subset?(ALL_ABILITIES)
      raise InvalidUserAbilitiesSetError
    end
  end
end
