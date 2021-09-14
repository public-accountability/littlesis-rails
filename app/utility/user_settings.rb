# frozen_string_literal: true

# Like a struct, but will silently remove any settings not currently defined
class UserSettings
  DEFAULTS = {
    default_tag: :oligrapher,
    show_stars: true  # admin-only setting
  }.freeze

  CONVERTERS = Hash.new(->(x) { x }).tap do |hash|
    hash[:default_tag] = ->(x) { x.to_sym }
    hash[:show_stars] = ->(x) { ActiveModel::Type::Boolean.new.cast(x) }
  end.with_indifferent_access.freeze

  SettingsStruct = Struct.new(*DEFAULTS.keys, keyword_init: true)

  attr_reader :settings
  delegate_missing_to :@settings

  def initialize(**kwargs)
    @settings = if kwargs.empty?
                  SettingsStruct.new(DEFAULTS)
                else
                  SettingsStruct.new(DEFAULTS.dup.merge!(kwargs.slice(*DEFAULTS.keys)))
                end

    @settings[:default_tag] = @settings[:default_tag].to_sym if @settings[:default_tag]
  end

  def update(hash)
    hash.each_pair do |k, v|
      send "#{k}=", CONVERTERS[k].call(v)
    end
  end

  def self.dump(obj)
    raise ActiveRecord::SerializationTypeMismatch unless obj.nil? || obj.is_a?(UserSettings)

    obj.settings.to_json
  end

  def self.load(obj)
    return new if obj.blank?

    raise ActiveRecord::SerializationTypeMismatch unless obj.is_a?(String)

    new(**JSON.parse(obj).symbolize_keys)
  end
end
