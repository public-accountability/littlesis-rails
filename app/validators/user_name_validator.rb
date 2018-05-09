# frozen_string_literal: true

# Restrictions for usernames
#   - minimun of 3 characters
#   - cannot start with a number
#   - contains only letters, numbers, underscores
class UserNameValidator  < ActiveModel::EachValidator
  USER_NAME_REGEX = /^[A-z]{1}[\d\w_]{2,}$/

  def validate_each(record, attribute, value)
    return if USER_NAME_REGEX.match?(value)

    # Technically that regex above is all we need to validate the username.
    # But these provide us some more descriptive error messages:
    if value.length < 3
      record.errors.add(attribute, 'must be at least 3 characters')
    elsif /\d/.match?(value[0])
      record.errors.add(attribute, 'cannot start with a number')
    elsif value.include?('!') || value.include?('.') || value.include?('@')
      record.errors.add(attribute, 'cannot include special characters')
    else
      record.errors.add(attribute, 'is invalid')
    end
  end
end
