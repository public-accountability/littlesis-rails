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
  ].freeze

  COMMON_PREFIXES = ['Mr', 'Mrs', 'Ms', 'Miss'].freeze

  SUFFIXES = [
    'JR', 'SR', 'Jr', 'Sr', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X', 'XI', 'XII', 'PHD', 'PhD', 'ESQ', 'Esq', 'MD',
    'MS', 'AG', 'AC', 'CM', 'JD', 'OP', 'RN', 'DNSC', 'MPH', 'OBE', 'RPH', 'SCD', 'RET', 'USA', 'DBA',
    'CBE', 'DVM', 'USN', 'USAF', 'EDD', 'OSB', 'MBA', 'SJD'
  ].freeze

  def initialize(str)
    parse(str)
  end

  def parse(str)
    return nil unless str.split(/\s+/mu).count > 1

    @raw = str

    prefix = first = middle = last = suffice = nick = nil
    
    # Ziggy & Austin on Thu 17 Aug 2017:
    # replaced this call with the str.split.capitalize below
    # in order to fix incorrect McLastNames
    #str = str.titleize
    
    str = str.gsub('.', '').strip       # trim and remove periods
             .gsub(/\s{2,}/, ' ')       # remove extra spaces
             .gsub(/ \([^\)]+\)/, '')   # remove anything in parentheses at the end
    
    str = str.split(' ').map(&:capitalize).join(' ')

    # get prefixes
    NameParser::PREFIXES.each do |pre|
      new = str.gsub(/^#{pre} /i, '')
      unless str == new # the case in which the string doesn't contain the prefix under consideration
        unless NameParser::COMMON_PREFIXES.map(&:downcase).include?(pre.downcase) # the case in which the prefix is a known common prefixg
          prefix = prefix.to_s + ' ' + pre + ' '
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
      str = str.gsub(/["\']([\S]+)[\'"]/, '').strip
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

  def to_h
    {
      name_prefix: @prefix,
      name_first: @first,
      name_middle: @middle,
      name_last: @last,
      name_suffix: @suffix,
      name_nick: @nick
    }
  end

  ##
  # Class Methods

  def self.parse_to_hash(str)
    parser = new(str)
    return false unless parser.first && parser.last
    parser.to_h
  end

  def self.parse_to_person(str)
    parser = new(str)
    return false unless parser.first && parser.last
    Person.new(parser.to_h)
  end

  def self.couple_name?(name)
    name.match(/&|\band\b/) and name.split(/&|\band\b/).last.strip.split(/\s/).count > 1
  end

  # parses name with these variations:
  # [blank] or nil
  # FIRST LAST
  # LAST, FIRST
  # LAST, FIRST M
  # LAST, FIRST MIDDLE
  # LAST, FIRST PREFIX
  # LAST, FIRST SUFFIX
  # LAST, FRIST M PREFIX
  # LAST, FRIST M SUFFIX
  def self.os_parse(str)
    last_name, first_name, middle_name, prefix, suffix = nil
    name = str.nil? ? [] : str.strip.upcase.split(',')

    if name.length.zero?
      # do nothing and return all nil hash
    elsif name.length == 1
      # If there is no comma in the name we will presume that the order is First Last
      first_name, last_name = name[0].strip.titleize.split(' ')
    else
      last_name = name[0].titleize
      rest_of_name = (name - [""])[1].split(' ') # remove blank strings in case of double comma
      first_name = rest_of_name[0].strip.titleize

      rest_of_name.drop(1).each do |name_part|
        if NameParser::PREFIXES.include? name_part.titleize
          prefix = name_part.titleize
        elsif NameParser::SUFFIXES.include? name_part
          suffix = name_part
        else
          middle_name = "" if middle_name.nil?
          middle_name << " " if middle_name.present?
          middle_name << name_part.titleize
        end
      end
    end

    {
      last: last_name,
      first: first_name,
      middle: middle_name,
      prefix: prefix,
      suffix: suffix
    }
  end
end
