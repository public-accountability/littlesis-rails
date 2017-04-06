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
class LsDate
  include Comparable
  attr_reader :date_string, :specificity, :year, :month, :day
  
  # Initialize with string YYYY-MM-DD
  def initialize(date_string)
    test_if_valid_input(date_string)
    @date_string = date_string
    set_year_month_day
    set_specificity
  end

  # specificity helpers
  [:unknown, :year, :month, :day].each do |specificity|
    define_method("sp_#{specificity}?") { @specificity == specificity } 
  end
  
  # ~~~~spaceship method~~~~
  def <=>(other)
    # one of the dates is unknown
    return 0 if sp_unknown? && other.sp_unknown?
    return 1 if !sp_unknown? && other.sp_unknown?
    return -1 if sp_unknown? && !other.sp_unknown?
    # If the years are different
    return -1 if @year < other.year
    return 1 if @year > other.year
    # year is the same, specificity is year for both
    if @year == other.year
      return 0 if sp_year? && other.sp_year?
      return -1 if sp_year? && (other.sp_month? || other.sp_day?)
      return 1 if (sp_month? || sp_day?) && other.sp_year?
    end
    # if the months are different
    return 1 if @month > other.month
    return -1 if @month < other.month
    # months are the same, one or both of them are are missing a day
    if @month == other.month
      return 0 if sp_month? && other.sp_month?
      return 1 if sp_day? && other.sp_month?
      return -1 if sp_month? && other.sp_day?
    end
    # if we get here then year and month have to be the same and specificity is :day for both LsDates
    if sp_day? && other.sp_day?
      return -1 if @day < other.day
      return 1 if @day > other.day
      return 0 if @day == other.day
    end
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

  # str -> str
  # converts string dates in the following formats:
  #   YYYY. Example: 1996 -> 1996-00-00
  #   YYY-MM. Example: 2017-01 -> 2017-01-00
  #   YYYYMMDD. Example: 20011231 -> 2001-12-31
  # Otherwise, it returns the input unchanged
  def self.convert(date)
    return date unless date.is_a? String
    return "#{date}-00-00" if /^\d{4}$/.match(date)
    return "#{date.slice(0,4)}-#{date.slice(5,2)}-00" if /^\d{4}-\d{2}$/.match(date)
    return "#{date.slice(0,4)}-#{date.slice(4,2)}-#{date.slice(6,2)}" if /^\d{8}$/.match(date)
    date
  end

  # string -> boolean
  # determines if string is a valid ls_date (used by date validator)
  def self.valid_date_string?(value)
    return false unless (value.length == 10) && (value.gsub('-').count == 2)
    year, month, day = year_month_day(value)
    return false unless valid_year?(year) && valid_month?(month) && valid_day?(day)
    true
  end
  
  # str -> [year, month, day]
  def self.year_month_day(value)
    value.split('-').map { |x| to_int(x) }
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
  rescue
    Rails.logger.debug "Failed to convert - #{x} - to an integer"
    nil
  end

  private_class_method def self.valid_year?(year)
    year.between?(1000,3000)
  end

  private_class_method def self.valid_month?(month)
    month.nil? || month.between?(1, 12)
  end

  private_class_method def self.valid_day?(day)
    day.nil? || day.between?(1, 31)
  end

  private

  def set_year_month_day
    return if @date_string.nil?
    @year, @month, @day = self.class.year_month_day(@date_string)
  end

  def set_specificity
    @specificity = :unknown if @year.nil? && @month.nil? && @day.nil?
    @specificity = :year if @year.present? && @month.nil? && @day.nil?
    @specificity = :month if @year.present? && @month.present? && @day.nil?
    @specificity = :day if @year.present? && @month.present? && @day.present?
  end

  def test_if_valid_input(str)
    return if str.nil? || self.class.valid_date_string?(str)
    Rails.logger.debug "Invalid LsDate input: #{str}"
    raise ArgumentError, "Not a valid date string"
  end

  def year_display
    "'#{@year.to_s[-2..-1]}"
  end

  def month_display
    "#{Date::ABBR_MONTHNAMES[@month]} #{year_display}"
  end

  def month_display_full
    "#{Date::MONTHNAMES[@month]} #{@year.to_s}"
  end

  def day_display
    "#{Date::ABBR_MONTHNAMES[@month]} #{@day} #{year_display}"
  end
end
