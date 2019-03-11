# frozen_string_literal: true

# Ensures that, if the entity is a person, the person has a last name
class EntityNameValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    return if org?(record)
    parsed_name = ::NameParser.new(value)
    return if parsed_name.valid?

    Rails.logger.debug "#{value} is an invalid name"

    if parsed_name.errors.empty?
      error_msg = 'appears to be missing a last name'
    else
      error_msg = parsed_name.errors.join('; ')
    end
    record.errors.add(attribute, error_msg)
  end

  private

  def org?(record)
    record.primary_ext == 'Org'
  end
end
