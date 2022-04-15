# frozen_string_literal: true

# Ensures that the person has a last name or the name is at least 3 characters long
class EntityNameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if record.primary_ext == 'Org'
      if value.is_a?(String) && value.length < 3
        record.errors.add(attribute, "is less than 3 characters")
      end
    else
      parsed_name = NameParser.new(value)
      unless parsed_name.valid?
        Rails.logger.debug { "#{value} is an invalid name" }
        record.errors.add(attribute, parsed_name.errors.join('; '))
      end
    end
  end
end
