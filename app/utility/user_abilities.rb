# frozen_string_literal: true

# This class is used by the column "abilities" on User.
# It holds the abilities (formally known as permissions) that the user can do.
# It's a wrapper around a `Set`.
#
# There are currently 7 abilities (plus admin)
#
#    edit -> basic editing opertions. All users have this by default
#    delete -> ability to delete entities, relationships, and lists
#    merge -> ability to merge entities together
#    bulk -> ability to bulk add unlmited entities, relationships, and lists
#    match -> ability to use the match donors tools
#    list  -> ability to add/remove entities from open lists
#    upload -> ability to upload documents
# Admins can do all of those plus use any admin-only features
#
class UserAbilities
  ABILITY_MAPPING = {
    :admin => :admin?,
    :edit => :editor?,
    :delete => :deleter?,
    :merge => :merger?,
    :bulk => :bulker?,
    :match => :matcher?,
    :list => :lister?,
    :upload => :uploader?,
    :essential => :essential?
  }.freeze

  ALL_ABILITIES = ABILITY_MAPPING.keys.to_set.freeze

  DESCRIPTIONS = {
    :admin => 'Site administrator. Only staff should have this ability.',
    :edit => 'Basic editing ability. Can add & edit lists, entities, and maps.',
    :delete => 'Ability to delete entities and lists',
    :merge => 'Ability to merge two entities together',
    :bulk => 'Ability to bulk import an unlimited # of entities and relationships',
    :match => 'Ability to match New York and federal donations',
    :list => 'Can add entities to any open list',
    :upload => 'Ability to upload primary source documents',
    :essential => 'Ability to edit when noediting is on'
  }.freeze

  extend Forwardable
  attr_reader :abilities
  def_delegators :@abilities, :empty?, :blank?, :to_a, :include?
  def_delegator 'self.class', :assert_valid_ability

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

  ABILITY_MAPPING.each do |(ability, method)|
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

  # test #

  def self.assert_valid_ability(value)
    unless ALL_ABILITIES.include?(value.to_sym)
      raise InvalidUserAbilityError, "#{value} is not a valid user ability"
    end
  end

  # Errors #
  class InvalidUserAbilitiesSetError < StandardError; end
  class InvalidUserAbilityError < StandardError; end

  private

  def assert_valid_abilities(values)
    values.each { |value| assert_valid_ability(value) }
  end

  def assert_valid_set(set)
    unless set.is_a?(Set) && set.subset?(ALL_ABILITIES)
      raise InvalidUserAbilitiesSetError
    end
  end
end
