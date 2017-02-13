class DateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.nil? || valid_date?(value)
      record.errors.add(attribute, 'is an invalid date')
    end
  end

  private

  def valid_date?(value)
    return false if value.length != 10
    year, month, day = value.split('-').map { |x| to_int(x) }
    return false unless year && month && day && month.between?(0, 12)
    true
  end

  # anything -> int or false
  def to_int(x)
    return false unless !x.nil? && x.length.between?(1, 4)
    x = x[1..-1] if x[0] == '0'
    Integer(x)
  rescue
    Rails.logger.debug "Failed to convert - #{x} - to an integer"
    false
  end
end
