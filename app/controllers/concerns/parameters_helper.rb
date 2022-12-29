# frozen_string_literal: true

# LittleSis helpers for ActionController::Paramters
module ParametersHelper
  YES_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE', 'True', 'yes', 'Yes', 'YES', 'Y', 'y', 'on', 'ON'].to_set.freeze
  NO_VALUES = [false, 0, '0', '00', 'f', 'F', 'false', 'False', 'FALSE', 'NO', 'N', 'no', 'No', 'n', 'off', 'OFF'].to_set.freeze
  NIL_VALUES = [nil, '', 'NULL', 'null', 'NIL', 'nil'].to_set.freeze

  private_constant :YES_VALUES
  private_constant :NO_VALUES

  # @param params [ActionController::Parameters, Hash]
  # @return [Hash]
  def self.prepare_params(params)
    h = Utility.nilify_blank_vals(params.to_h)
    h['start_date'] = LsDate.convert(h['start_date']) if h.key?('start_date')
    h['end_date'] = LsDate.convert(h['end_date']) if h.key?('end_date')
    h['is_current'] = cast_to_boolean(h['is_current']) if h.key?('is_current')
    h['amount'] = money_to_int(h['amount']) if h.key?('amount')
    h
  end

  # The value can be marked as nil
  #     cast_to_boolean('null') => nil
  # @return [False, True, Nil]
  def self.cast_to_boolean(value)
    return true if YES_VALUES.include?(value)
    return false if NO_VALUES.include?(value)
    return nil if NIL_VALUES.include?(value)

    ActiveRecord::Type::Boolean.new.deserialize(value)
  end

  # @param money [Integer, String, Nil]
  # @return [Integer, Nil]
  def self.money_to_int(money)
    case money
    when Integer, NilClass
      money
    when String
      money.strip.tr('$', '').tr(',', '').to_i
    else
      raise TypeError
    end
  end

  def self.blank_to_nil(hash)
    Utility.nilify_blank_vals(hash)
  end
end
