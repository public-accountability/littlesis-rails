# frozen_string_literal: true

# A class for dates in LittleSis
#
# Dates are represented by a 10 char string
# with the format: YYYY-MM-DD
# year is required, but month and day are optional.
# When missing or unknown, month and day can be represented as '00'.
#
# Usage:
#  when instantiating an lsDate object, new requires the input to be in a valid date format:
#    ✓ LsDate.new('2005-02-04')
#    ❌ LsDate.new('Feburary 4th, 2005')
#
# Examples of handling input from other formats:
#
#  LsDate.parse('2010') --> LsDate.new('2010-00-00')
#  LsDate.parse('foobar') --> LsDate.new(nil)
#  LsDate.parse!('foobar') --> raises InvalidLsDateError
#  LsDate.parse!('1 May, 1970') --> LsDate.new('1970-05-01')
#  LsDate.transform_date('1 May, 1970') --> "1970-05-01"
#  LsDate.convert('1 May, 1970') --> "1970-05-01"
#  LsDate.transform_date('foobar') --> raises InvalidLsDateError
#  LsDate.convert('foobar') --> 'foobar'
#
class LsDate # rubocop:disable Metrics/ClassLength
  include Comparable
  attr_reader :date_string, :specificity, :year, :month, :day

  delegate :validate_date_string, :split_ls_date_string, to: :class

  DATE_TRANSFORMERS = {
    %r{(?<day>^\d{2})\/(?<month>\d{2})\/(?<year>\d{4})$} =>
      ->(m) { "#{m[:year]}-#{m[:month]}-#{m[:day]}" },

    /(?<year>^\d{4})(?<month>\d{2})(?<day>\d{2})$/ =>
      ->(m) { "#{m[:year]}-#{m[:month]}-#{m[:day]}" },

    %r{(?<month>^\d{2})\/(?<year>\d{4})$} =>
      ->(m) { "#{m[:year]}-#{m[:month]}-00" },

    /(?<year>^\d{4})-(?<month>\d{2})$/ =>
      ->(m) { "#{m[:year]}-#{m[:month]}-00" },

    /(?<year>^\d{4}$)/ => ->(m) { "#{m[:year]}-00-00" },

    /(?<month_name>([a-zA-Z]{3,}))-(?<year>\d{2})/ =>
      ->(m) { "#{year_with_millennium(m[:year])}-#{month_no_from_name(m[:month_name])}-00" }
  }.freeze

  def initialize(date_string)
    unless date_string.nil?
      validate_date_string(date_string)
      @date_string = date_string
      @year, @month, @day = split_ls_date_string(@date_string) unless @date_string.nil?
    end

    @specificity = :unknown if @year.nil?
    @specificity = :year if @year.present? && @month.nil? && @day.nil?
    @specificity = :month if @year.present? && @month.present? && @day.nil?
    @specificity = :day if @year.present? && @month.present? && @day.present?
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
  # return nil if specificity is unknown
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

  # LsDate.convert returns a string and LsDate.parse returns an LsDate instance
  def self.parse(str)
    parse!(str)
  rescue InvalidLsDateError
    new(nil)
  end

  def self.parse!(str)
    new transform_date(str)
  end

  # like transform_date, but it suppresses invalid date strings and returns the input unchanged.
  def self.convert(date)
    transform_date(date)
  rescue InvalidLsDateError
    Rails.logger.debug "Failed to convert date string #{date}"
    date
  end

  # converts string dates in the following formats:
  #   YYYY. Example: 1996 -> 1996-00-00
  #   YYYY-MM. Example: 2017-01 -> 2017-01-00
  #   YYYYMMDD. Example: 20011231 -> 2001-12-31
  #   MM/YYYY. Example: 04/2015 --> 2015-04-00
  #
  #   + Any format accepted by DateTime.parse
  #
  # Nil and empty strings and returned as nil.
  # Raises InvalidLsDateError if it cannot be transformed
  def self.transform_date(date)
    TypeCheck.check date, String, allow_nil: true
    return nil if date.blank?

    DATE_TRANSFORMERS.each_pair do |regex, formatter|
      match = regex.match date
      next unless match

      match.named_captures.each do |k, v|
        break unless send("valid_#{k}?", v)

        return formatter.call(match)
      end
    end

    parse_with_datetime(date)
  end

  # string -> boolean
  def self.valid_date_string?(str)
    return false unless valid_string_structure?(str)

    year, month, day = split_ls_date_string(str)

    valid_year?(year) && valid_month?(month) && valid_day?(day)
  end

  # String --> void | raises InvalidDateError
  def self.validate_date_string(str)
    unless valid_string_structure?(str)
      raise InvalidLsDateError, "\"#{str}\" is not formatted correctly"
    end

    year, month, day = split_ls_date_string(str)

    raise InvalidLsDateError, "#{year} is not a valid year" unless valid_year?(year)
    raise InvalidLsDateError, "#{month} is not a valid month" unless valid_month?(month)
    raise InvalidLsDateError, "#{day} is not a valid day" unless valid_day?(day)
  end

  # str -> [<int>, <int>, <int>]
  def self.split_ls_date_string(str)
    str.split('-').map { |x| to_int(x) }
  end

  # CMP dates are in the following format:
  # - MM/DD/YYYY
  # - MM/YYYY
  # - YYYY
  def self.parse_cmp_date(date)
    parse(date)
  end

  # FEC dates are MMDDYYYY
  def self.parse_fec_date(dstr)
    Date.strptime(dstr, "%m%d%Y")
  rescue Date::Error
    nil
  end

  def self.today
    new(Time.zone.today.iso8601)
  end

  def self.parse_us_date(d)
    return nil if d.blank?

    Date.strptime(d, '%m/%d/%Y')
  rescue Date::Error
    nil
  end

  def self.parse_us_datetime(d)
    return nil if d.blank?

    DateTime.strptime(d, '%m/%d/%Y %T')
  rescue Date::Error
    nil
  end

  # converts strings to integers and converts 0 to nil
  private_class_method def self.to_int(x)
    return nil if x.blank?

    i = x.to_i

    if i.zero?
      nil
    else
      i
    end
  rescue # rubocop:disable Style/RescueStandardError
    Rails.logger.debug "Failed to convert - #{x} - to an integer"
    nil
  end

  private_class_method def self.parse_with_datetime(str)
    DateTime.parse(str).strftime('%Y-%m-%d')
  rescue ArgumentError => e
    if e.message == 'invalid date'
      raise InvalidLsDateError, "#{str} is an invalid date"
    else
      raise
    end
  end

  private_class_method def self.valid_string_structure?(str)
    /\A\d{4}-\d{2}-\d{2}\Z/.match? str
  end

  private_class_method def self.valid_year?(year)
    year.to_i.between?(1000, 3000)
  end

  private_class_method def self.valid_month?(month)
    month.blank? || month.to_i.between?(1, 12)
  end

  private_class_method def self.valid_month_name?(month_name)
    valid_month?(Date.parse(month_name.to_s).strftime('%m'))
  rescue ArgumentError
    false
  end

  private_class_method def self.valid_day?(day)
    day.blank? || day.to_i.between?(1, 31)
  end

  private_class_method def self.month_no_from_name(name)
    Date.parse(name).strftime('%m')
  end

  private_class_method def self.year_with_millennium(year)
    if year_without_millennium?(year)
      current_millennium?(year) ? "20#{year}" : "19#{year}"
    elsif valid_year?(year)
      return year
    else
      raise ArgumentError
    end
  end

  private_class_method def self.year_without_millennium?(year)
    year.match(/^\d{2}$/)
  end

  private_class_method def self.current_millennium?(year)
    year.to_i.between?(0, 5.years.from_now.strftime('%y').to_i)
  end

  private

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
    def initialize(msg = nil)
      super(msg || 'Not a valid date string')
    end
  end
end
