# frozen_string_literal: true

# A class for dates in LittleSis
#
# Dates are represented by a 10 char string
# with the format: YYYY-MM-DD
# year is required, but month and day are optional.
# When missing or unknown, month and day can be represented as '00'.
#
# Examples:
#    May, 1968 -> '1968-05-00'
#    April 1, 2017 -> '2017-02-01'
#    The year 1975 -> '1975-00-00'
class LsDate # rubocop:disable Metrics/ClassLength
  include Comparable
  attr_reader :date_string, :specificity, :year, :month, :day

  DATE_TRANSFORMERS = {
    %r{(?<day>^\d{2})\/(?<month>\d{2})\/(?<year>\d{4})$} =>
      ->(m) { "#{m[:year]}-#{m[:month]}-#{m[:day]}" },

    /(?<year>^\d{4})(?<month>\d{2})(?<day>\d{2})$/ =>
      ->(m) { "#{m[:year]}-#{m[:month]}-#{m[:day]}" },

    %r{(?<month>^\d{2})\/(?<year>\d{4})$} =>
      ->(m) { "#{m[:year]}-#{m[:month]}-00" },

    /(?<year>^\d{4})-(?<month>\d{2})$/ =>
      ->(m) { "#{m[:year]}-#{m[:month]}-00" },

    /(?<year>^\d{4}$)/ => ->(m) { "#{m[:year]}-00-00" }
  }.freeze

  def initialize(date_string)
    test_if_valid_input(date_string)
    @date_string = normalize_input(date_string)
    set_year_month_day
    set_specificity
  end

  def normalize_input(string)
    if /\A\d{4}-\d{2}-\d{2}\Z/.match? string
      string
    elsif string.nil?
      string
    else
      DateTime.parse(string).strftime('%Y-%m-%d')
    end
  end

  # specificity helpers
  [:unknown, :year, :month, :day].each do |specificity|
    define_method("sp_#{specificity}?") { @specificity == specificity }
  end

  def <=>(other)
    date_string.to_s <=> other.date_string.to_s
  end

  def to_s
    @date_string
  end

  # display string of date
  def display
    return '?' if sp_unknown?
    return year_display if sp_year?
    return month_display if sp_month?
    return day_display if sp_day?
  end

  # alternative display string
  def basic_info_display
    return '' if sp_unknown?
    return @year.to_s if sp_year?
    return month_display_full if sp_month?
    return day_display if sp_day?
  end

  # returns <Date> instance
  # Raises error unless date has a valid month and day
  # return nil if specifiy is unknown
  def to_date
    return nil if sp_unknown?

    Date.parse(@date_string)
  end

  # returns <Date> instance
  # Unlike `to_date` this will assign 1 for the
  # first month and/or day if they are missing
  def coerce_to_date
    return nil if sp_unknown?
    return to_date if sp_day?

    Date.parse(coerce_to_date_str)
  end

  def coerce_to_date_str
    return @date_string if sp_day?
    return "#{year}-01-01" if sp_year?
    return "#{year}-#{month}-01" if sp_month?
  end

  # converts string dates in the following formats:
  #   YYYY. Example: 1996 -> 1996-00-00
  #   YYYY-MM. Example: 2017-01 -> 2017-01-00
  #   YYYYMMDD. Example: 20011231 -> 2001-12-31
  #   MM/YYYY. Example: 04/2015 --> 2015-04-00
  #
  # It turns blank strings into nil.
  # Otherwise, it returns the input unchanged
  def self.convert(date)
    return date unless date.is_a? String

    return nil if date.blank?

    return transform_date(date) || date
  end

  def self.transform_date(date)
    output = nil
    DATE_TRANSFORMERS.each_pair do |regex, formatter|
      match = regex.match date
      next unless match

      match.named_captures.each do |k, v|
        break unless send("valid_#{k}?", v.to_i)

        output = formatter.call(match)
      end
    end
    output
  end

  # string -> boolean
  # determines if string is a valid ls_date (used by date validator)
  def self.valid_date_string?(value)
    return true if DateTime.parse(value)
  rescue ArgumentError
    valid_ls_date?(value)
  end

  # str -> [year, month, day]
  def self.year_month_day(value)
    value.split('-').map { |x| to_int(x) }
  end

  # CMP dates are in the following format:
  # - MM/DD/YYYY
  # - MM/YYYY
  # - YYYY
  # str ---> LsDate | nil
  # returns nil if date is invalid or missing
  def self.parse_cmp_date(date)
    transform_date(date)
  end

  def self.today
    new(Time.zone.today.iso8601)
  end

  # anything -> int or nil
  # converts strings to integers
  # converts '00' and '0' to nil
  private_class_method def self.to_int(x)
    return false unless !x.nil? && x.length.between?(1, 4)

    x = x[1..-1] if x[0] == '0'
    int = Integer(x)
    return nil if int.zero?

    int
  rescue # rubocop:disable Style/RescueStandardError
    Rails.logger.debug "Failed to convert - #{x} - to an integer"
    nil
  end

  private_class_method def self.valid_year?(year)
    year.between?(1000, 3000)
  end

  private_class_method def self.valid_month?(month)
    month.nil? || month.between?(1, 12)
  end

  private_class_method def self.valid_day?(day)
    day.nil? || day.between?(1, 31)
  end

  private_class_method def self.valid_ls_date?(value)
    return false unless (value.length == 10)\
      && (value.gsub('-').count == 2)\
      && blank_month_or_year?(value)

    year, month, day = year_month_day(value)

    valid_year?(year) && valid_month?(month) && valid_day?(day)
  end

  private_class_method def self.blank_month_or_year?(value)
    value.include? '-00'
  end

  private

  def set_year_month_day
    return if @date_string.nil?

    @year, @month, @day = self.class.year_month_day(@date_string)
  end

  def set_specificity
    @specificity = :unknown
    [:year, :month, :day].each do |sp|
      @specificity = sp if instance_variable_get("@#{sp}").present?
    end
  end

  def test_if_valid_input(str)
    return if str.nil? || self.class.valid_date_string?(str)

    Rails.logger.debug "Invalid LsDate input: #{str}"
    raise InvalidLsDateError
  end

  def year_display
    "'#{@year.to_s[-2..-1]}"
  end

  def month_display
    "#{Date::ABBR_MONTHNAMES[@month]} #{year_display}"
  end

  def month_display_full
    "#{Date::MONTHNAMES[@month]} #{@year}"
  end

  def day_display
    "#{Date::ABBR_MONTHNAMES[@month]} #{@day} #{year_display}"
  end

  class InvalidLsDateError < StandardError
    def message
      'Not a valid date string'
    end
  end
end
