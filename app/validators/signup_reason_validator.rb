class SignupReasonValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if record.persisted?
    unless two_or_more_words?(value)
      record.errors.add(attribute, "must be at least two words") 
    end
  end

  private

  def two_or_more_words?(value)
    return false unless value.present?
    value.split(' ').length >= 2
  end
end
