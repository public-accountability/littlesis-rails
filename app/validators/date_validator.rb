# frozen_string_literal: true

class DateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.nil? || LsDate.valid_date_string?(value)
      record.errors.add(attribute, 'is an invalid date')
      return
    end

    # check if start_date and end_date are ordered correctly

    return unless %i[start_date end_date].include?(attribute) &&
                  record.respond_to?(:start_date) &&
                  record.respond_to?(:end_date) &&
                  record.start_date.present? &&
                  record.end_date.present? &&
                  LsDate.valid_date_string?(record.start_date) &&
                  LsDate.valid_date_string?(record.end_date)

    if attribute == :start_date && LsDate.new(value) > LsDate.new(record.end_date)
      record.errors.add(attribute, 'is chronologically inconsistent with the current end_date')
    end

    if attribute == :end_date && LsDate.new(record.start_date) > LsDate.new(value)
      record.errors.add(attribute, 'is chronologically inconsistent with the current start_date')
    end
  end
end
