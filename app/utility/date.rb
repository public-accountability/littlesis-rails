class Date

  BLANK_SPECIFIC = 0
  YEAR_SPECIFIC = 1
  MONTH_SPECIFIC = 2
  DAY_SPECIFIC = 3
  COMPARE_AFTER = 1
  COMPARE_SAME = 0
  COMPARE_BEFORE = -1
  COMPARE_UNKNOWN = nil

  def initialize(str)
    year, month, day = str.split('-').map { |f| f == '00' ? nil : f } if str.present?
  end

  def how_specific
    return DAY_SPECIFIC if @day.present?
    return MONTH_SPECIFIC if @month.present?
    return YEAR_SPECIFIC if @year.present?
    BLANK_SPECIFIC
  end

  def format
    return nil unless @year.present?
    [@year, @month, @day].map { |f| f.nil? ? '00' : f }.join('-')
  end

  def self.compare(date1, date2)
    return COMPARE_UNKNOWN if date1.year.blank? ^ date2.year.blank?
    return COMPARE_AFTER if date1.year > date2.year
    return COMPARE_BEFORE if date1.year < date2.year

    return COMPARE_AFTER if date1.month > date2.month and date2.month.present?
    return COMPARE_BEFORE if date1.month < date2.month and date1.month.present?

    if date1.month == date2.month
      return COMPARE_AFTER if date1.day > date2.day and date2.day.present?
      return COMPARE_BEFORE if date1.day < date2.day and date1.day.present?
      return COMPARE_SAME if date1.day == date2.day
    end

    COMPARE_UNKNOWN
  end

  def self.less_or_equal(date1, date2)
    [COMPARE_BEFORE, COMPARE_SAME].include?(compare(date1, date2))
  end
end