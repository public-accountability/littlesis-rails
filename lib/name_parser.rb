class NameParser

  attr_reader :prefix, :first, :middle, :last, :suffix, :nick, :raw

  PREFIXES = [
    'Honorable',
    'General',
    'Lieutenant',
    'Colonel',
    'Corporal',
    'Senator',
    'Representative',
    'Minister',
    'Mr', 'Ms', 'Mrs', 'Miss', 'Dr', 'Rev', 'Hon', 'Prof', 'Rt', 'Gen', 'Adm', 'Br', 'Fr', 'Rabbi', 'Sr', 
    'Sen', 'Cpt', 'Capt', 'Cdr', 'Col', 'Amn', 'Cpl', 'Ens', 'Lt', 'Maj', 'Pvt', 'Sgt', 'Msg', 'Rep','Sir'
  ]

  COMMON_PREFIXES = [
    'Mr', 'Mrs', 'Ms', 'Miss'
  ]

  SUFFIXES = [
    'Jr', 'Sr', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X', 'XI', 'XII', 'PhD', 'Esq', 'MD',  
    'MS', 'AG', 'AC', 'CM', 'JD', 'OP', 'RN', 'DNSC', 'MPH', 'OBE', 'RPH', 'SCD', 'RET', 'USA', 'DBA', 
    'CBE', 'DVM', 'USN', 'USAF', 'EDD', 'OSB', 'MBA', 'SJD'
  ]

  def initialize(str)
    parse(str)
  end

  def parse(str)
    @raw = str

    prefix = first = middle = last = suffice = nick = nil

    str = str.titleize

    str = str.gsub('.', '').strip       # trim and remove periods
             .gsub(/\s{2,}/, ' ')       # remove extra spaces
             .gsub(/ \([^\)]+\)/, '')   # remove anything in parentheses at the end
    
    # get prefixes
    prefixes = NameParser::PREFIXES
    prefixes.each do |pre|
      new = str.gsub(/^#{pre} /i, '')
      unless str == new
        unless NameParser::COMMON_PREFIXES.map(&:downcase).include?(str.downcase)
          prefix = prefix.to_s + pre + ' '
        end

        str = new.strip
      end
    end
    prefix = prefix.strip if prefix

    # get suffixes
    suffixes = NameParser::SUFFIXES
    suffixes.each do |suf|
      new = str.gsub(/ #{suf}$/i, '')
      unless str == new
        suffix = suf + ' ' + suffix.to_s
        str = new.strip
      end
    end
    suffix = suffix.strip if suffix

    # remove commas left over from suffixes
    str = str.gsub(',', '').strip

    # find nickname in quotes
    str.match(/["\']([\S]+)[\'"]/) do |match|
      nick = match[1] ? match[1] : match[2]
      str = stre.gsub(/["\']([\S]+)[\'"]/, '').strip
    end

    # condense multiple spaces
    str = str.gsub(/\s{2,}/, ' ')

    # split into parts
    parts = str.split(' ')

    case parts.count
    when 1
      if prefix
        first = prefix
        last = parts.first
        prefix = nil
      elsif suffix
        first = parts.first
        last = suffix
        suffix = nil
      else
        first = parts.first
      end
    when 2
      first = parts.first
      last = parts.last
    when 3
      first = parts[0]
      middle = parts[1]
      last = parts[2]
    else
      first = parts.first
      last = parts.last
      middle = parts.drop(1).take(parts.count - 2).join(' ')
    end

    last = last.gsub('_', ' ')

    @first = first
    @last = last
    @middle = middle
    @prefix = prefix
    @suffix = suffix
    @nick = nick

    return self
  end
end