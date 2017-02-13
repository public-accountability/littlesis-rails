# Ensures that, if the entity is a person, the person has a last name
class EntityNameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless org?(record) || valid_name?(value)
      record.errors.add(attribute, 'appears to be missing a last name')
    end
  end

  private

  def valid_name?(value)
    return false if value.blank?
    value.split(' ').length > 1
  end

  def org?(record)
    record.primary_ext == 'Org'
  end
end
