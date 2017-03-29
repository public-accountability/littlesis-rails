class DateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.nil? || LsDate.valid_date_string?(value)
      record.errors.add(attribute, 'is an invalid date')
    end
  end
end
