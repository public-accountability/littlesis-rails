# frozen_string_literal: true

class CssColorValidator < ActiveModel::EachValidator
  HEX = Regexp.new '^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$'
  RGB = Regexp.new '^rgb\([0-9]{1,3},[ ]?[0-9]{1,3},[ ]?[0-9]{1,3}\)$'
  RGBA = Regexp.new '^rgba\([0-9]{1,3},[ ]?[0-9]{1,3},[ ]?[0-9]{1,3},[ ]?((1\.0)|(0\.[0-9]{1,2}))\)$'

  def validate_each(record, attribute, value)
    return if value.nil?

    unless HEX.match?(value) || RGB.match?(value) || RGBA.match?(value)
      record.errors.add attribute, "Invalid css color: #{value}"
    end
  end
end
