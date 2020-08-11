# frozen_string_literal: true

# Like a struct, but will silently remove any settings not currently defined
class UserSettings
  DEFAULTS = {
    oligrapher_beta: false
  }.freeze

  SettingsStruct = Struct.new(*DEFAULTS.keys, keyword_init: true)

  extend Forwardable
  attr_reader :settings

  def_delegators :@settings, :to_h, :[], :each_pair, *DEFAULTS.keys

  def initialize(**kwargs)
    @settings = if kwargs.empty?
                  SettingsStruct.new(DEFAULTS)
                else
                  SettingsStruct.new(DEFAULTS.dup.merge!(kwargs.slice(*DEFAULTS.keys)))
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
