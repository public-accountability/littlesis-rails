class LsDate < Date
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
end
