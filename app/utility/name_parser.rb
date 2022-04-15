# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength, Metrics/AbcSize, Metrics/MethodLength
# rubocop:disable Metrics/PerceivedComplexity, Style/WordArray
#
# === Parses string names into components: prefix, first, middle, last, suffix, and nick
#     In LittleSis names are required to have a first and last name
#
class NameParser
  class InvalidPersonNameError < Exceptions::LittleSisError
    def message
      "NameParser could not find a first and last name"
    end
  end

  attr_reader :prefix, :first, :middle, :last, :suffix, :nick,
              :raw, :errors

  attr_internal :parts

  PREFIXES = [
    # common
    'Sir',
    'Madam',
    'Mr',
    'Ms',
    'Mrs',
    'Miss',
    'Mme',
    'Mister',
    'Mast', 'Master',
    # Police and military
    'General', 'Gen',
    'Lieutenant', 'Lt',
    'Colonel', 'Col',
    'Corporal', 'Cpl',
    'Captain', 'Cpt', 'Capt',
    'Cdr',
    'Amn',
    'Ens',
    'Major', 'Maj',
    'Private', 'Pvt',
    'Sargent', 'Sgt',
    'Admiral', 'Adm',
    'Detective', 'Det',
    'Inspector', 'Insp',
    'Pte',
    # Political & Legal
    'Senator', 'Sen',
    'Representative', 'Rep',
    'Councilmember',
    'Mayor',
    'Judge',
    'Honorable', 'Hon',
    'Alderman', 'Ald',
    # Medical and education
    'Dr', 'Doctor',
    'Prof', 'Professor',
    # Religious
    'Minister',
    'Rev',
    'Rt',
    'Brother', 'Br',
    'Father', 'Fr',
    'Mother',
    'Rabbi',
    'Chaplain',
    'Sr',
    # Other
    'Msg',
    'Lord',
    'Lady',
    'Dame',
    'King',
    'Queen',
    'Sheik', 'Shayk', 'Shekh'
  ].to_set.freeze

  COMMON_PREFIXES = ['Mr', 'Mrs', 'Ms', 'Miss'].freeze

  SUFFIXES = [
    'JR', 'Jr',
    'SR', 'Sr',
    'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X', 'XI', 'XII', 'XIII',
    'PHD', 'PhD',
    'ESQ', 'Esq', 'Esquire',
    'MD', 'Md',
    'MS', 'Ms',
    'MSC', 'MSc',
    'AG',
    'AC',
    'CM',
    'JD',
    'OP',
    'RN',
    'DNSC',
    'MPH',
    'OBE',
    'RPH',
    'SCD',
    'RET',
    'USA',
    'DBA',
    'CBE',
    'DVM',
    'USN',
    'USAF',
    'EDD',
    'OSB',
    'MBA',
    'SJD'
  ].to_set.freeze

  LASTNAME_PREFIXES = [
    'abu',
    'bin',
    'bon',
    'da',
    'dal',
    'de',
    'degli',
    'dei',
    'del',
    'dela',
    'della',
    'delle',
    'delli',
    'dello',
    'der',
    'di',
    'du',
    'dí',
    'ibn',
    'la',
    'le',
    'san',
    'santa',
    'st',
    'ste',
    'van',
    'vel',
    'von'
  ].to_set.freeze

  HAS_LASTNAME_PREFIX = Regexp.new " (#{LASTNAME_PREFIXES.to_a.join('|')}) "

  IN_QUOTES = /^"(\w+)"$/
  IN_PARENS = /^\((\w+)\)$/

  # Matches "A.B." and "A. B."
  ABBREVIATED_INITIALS = /\A[[:alpha:]]\.[[:space:]]?[[:alpha:]]\.\Z/
  # Matches names with abbreviated first and middle names:  A. B. Lastname
  ABBREVIATED_FIRST_MIDDLE = /\A(?<first_middle>[[:alpha:]]\.[[:space:]]?([[:alpha:]]\.)?)([[:space:]](?<last_name>[[:alpha:]]{2,}))\Z/

  MC_NAME = /\b[Mm]a?c[A-Za-z]{2,}\b/

  MAC_EXCEPTIONS = [
    'macedo', 'macevicius', 'machado', 'machar', 'machin',
    'machlin', 'macias', 'maciulis', 'mackie',
    'mackle', 'macklin', 'mackmin', 'macquarie'
  ].to_set.freeze

  def initialize(str = '')
    @errors = []
    str = '' if str.nil?

    unless str.is_a?(String)
      raise Exceptions::LittleSisError, "NameParser must be initalized with a string"
    end

    @raw = str.strip
    @_parts = split_name(str)
    parse
    prettify!
  end

  def to_s
    [@prefix, @first, (@nick ? "\"#{@nick}\"" : nil), @middle, @last]
      .select(&:present?)
      .join(' ')
  end

  # Returns parased name as hash, formatted for +Person+
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

  def valid?
    @errors.empty?
  end

  def validate!
    raise InvalidPersonNameError unless valid?

    self
  end

  def middle_initial
    return nil unless @middle

    @middle[0].upcase
  end

  private

  def split_name(str)
    names = str.split(/\s+/u)
    return names unless HAS_LASTNAME_PREFIX.match?(str)

    out = []

    while names.length.positive?
      name_part = names.shift
      if LASTNAME_PREFIXES.include?(name_part)
        out << "#{name_part} #{names.shift}"
      else
        out << name_part
      end
    end

    return out
  end

  # sets the component attributes
  def parse
    if abbreviated_match = ABBREVIATED_FIRST_MIDDLE.match(@raw)
      @first = abbreviated_match[:first_middle]
      @last = abbreviated_match[:last_name]
      return
    end

    case parts.length
    when 0
      @errors << "is an empty string."
    when 1
      @errors << "is only one word. Valid names are at least two words."
      @last = parts.first
    when 2
      parse_double_word
    when 3
      extract_nick
      if parts.length == 2
        parse_double_word
      else
        parse_triple_word
      end
    else
      parse_long
    end
  end

  def parse_long
    extract_nick
    return parse_triple_word if parts.length == 3
    # In situations when  we have many names extra names wils become appended to the middle name
    @middle = []

    # last, first middle, [middle]
    # last, prefix first middle [middle] ...
    if ends_with_comma(parts[0])
      @last = parts[0]
      if prefix?(parts[1])
        @prefix = parts[1]
        @first = parts[2]
        @middle = parts.drop(3)
      else
        @first = parts[1]
        @middle = parts.drop(2)
      end

    # last suffix, first middle
    # last suffix, prefix first
    # last suffix, prefix first middle
    elsif ends_with_comma(parts[1]) && suffix?(parts[1])
      @last = parts[0]
      @suffix = parts[1]

      if prefix?(parts[2])
        @prefix = parts[2]
        @first = parts[3]
        @middle = parts.drop(4)
      else
        @first = parts[2]
        @middle = parts.drop(3)
      end

    # prefix first middle [middle] last
    # prefix first last suffix
    # prefix first middle [middle] last suffix
    elsif prefix?(parts[0])
      @prefix, @first = parts.take(2)

      if suffix?(parts.last)
        @last, @suffix = parts.last(2)
        # the "2" here excludes the prefix and first name
        # the "-3" here excludes last and suffix
        @middle = parts[2..-3]
      else
        @last = parts.last
        @middle = parts[2..-2]
      end

    # first middle [middle] ... last
    # first middle [middle] ... last suffix
    else
      @first = parts.first

      if suffix?(parts.last)
        @last, @suffix = parts.last(2)
        # the "1" here excludes the first name
        # the "-3" here excludes last and suffix
        @middle = parts[1..-3]
      else
        @last = parts.last
        @middle = parts[1..-2]
      end
    end
  end

  def parse_triple_word
    # Case when first word is a known prefix. There is only one valid outcome in this situation: PREFIX FIRST LAST
    # It will record an error message if this pattern -- PREFIX LAST SUFFIX -- is found
    if prefix?(parts[0])
      if suffix?(parts[2])
        @prefix, @last, @suffix = parts
        @errors << "#{@raw} has both a suffix and prefix and no apparent first name"
      else
        @prefix, @first, @last = parts
      end

    # Cases:
    #   FIRST MIDDLE LAST
    #   FIRST LAST SUFFIX
    #   FIRST LAST, SUFFIX
    #   FIRST "NICK" LAST
    #   LAST, FIRST MIDDLE
    #   LAST, PREFIX FIRST
    #   LAST SUFFIX, FIRST
    else
      # LAST, PREFIX FIRST
      if ends_with_comma(parts[0]) && prefix?(parts[1])
        @last, @prefix, @first = parts

      # LAST, FIRST PREFIX
      # This format is found in FEC's candidate data
      elsif ends_with_comma(parts[0]) && prefix?(parts[2])
        @last, @first, @prefix = parts

      # LAST, FIRST MIDDLE
      elsif ends_with_comma(parts[0]) && !prefix?(parts[1])
        @last, @first, @middle = parts

      # FIRST LAST SUFFIX
      # FIRST LAST, SUFFIX
      elsif suffix?(parts[2])
        @first, @last, @suffix = parts
      # LAST SUFFIX, FIRST
      elsif ends_with_comma(parts[1]) && suffix?(parts[1])
        @last, @suffix, @first = parts
      # FIRST MIDDLE LAST
      else
        @first, @middle, @last = parts
      end
    end
  end

  # Parses input that is only two words
  # Handles two cases:
  #  First Last
  #  Last, First
  # If first name or last name is is the list of prefixes or suffixes, respectively,
  # it will mark theses as nil
  def parse_double_word
    parts.reverse! if ends_with_comma(parts[0])
    maybe_first, maybe_last = parts

    if common_prefix? maybe_first
      @errors << "Could not find a first name. #{maybe_first} is a common prefix"
      @prefix = maybe_first
    else
      @first = maybe_first
    end

    if suffix? maybe_last
      @errors << "could not find a last name. #{maybe_last} is a known suffix"
      @suffix = maybe_last
    else
      @last = maybe_last
    end
  end

  ##
  # Helpers

  def prefix?(name)
    PREFIXES.include? clean(name).capitalize
  end

  def common_prefix?(name)
    COMMON_PREFIXES.include? clean(name).capitalize
  end

  def suffix?(name)
    SUFFIXES.include? clean(name).upcase
  end

  def extract_nick
    # find location of a name in quotes
    nick_index = parts.index { |x| quoted?(x) }
    # remove nickname from parts array if it exists
    @nick = parts.delete_at(nick_index) if nick_index
    # find location of a name in ()
    nick_index = parts.index { |x| in_parens?(x) }
    if nick_index
      nick = parts.delete_at(nick_index).tr('(', '').tr(')', '')
      if @nick.nil?
        @nick = nick
      else
        @nick = "#{@nick} #{nick}"
      end
    end
  end

  def ends_with_comma(str)
    str[-1] == ','
  end

  def quoted?(str)
    IN_QUOTES.match? str
  end

  def in_parens?(str)
    IN_PARENS.match? str
  end

  def clean(str, keep_periods: false)
    if keep_periods
      str.tr(',', '').tr('"', '')
    else
      str.tr(',', '').tr('"', '').tr('.', '')
    end
  end

  def capitalize_hyphenated_name(name)
    name
      .split('-')
      .map { |n| smart_capitalize(n) }
      .join('-')
  end

  def smart_capitalize(s)
    if MC_NAME.match?(s.downcase) && !MAC_EXCEPTIONS.include?(s.downcase)
      s.match(/\b(ma?c)(\S+)/i)[1..2].map(&:capitalize).join
    else
      s.capitalize
    end
  end

  def simple_capitalize(s)
    clean(s).capitalize
  end

  def prettify(str, keep_periods: false)
    name = clean(str, keep_periods: keep_periods)
    # simple case where name has no hyphen or spaces
    return smart_capitalize(name) unless str.include?('-') || str.include?(' ')

    name = name.split(' ').map { |x| capitalize_hyphenated_name(x) }.join(' ')

    return name unless name.include?(' ')

    lastname_prefix = name.split(' ')[0].downcase

    if LASTNAME_PREFIXES.include?(lastname_prefix)
      return ([lastname_prefix] + name.split(' ')[1..-1]).join(' ')
    else
      return smart_capitalize(name)
    end
  end

  def prettify!
    if @first
      if ABBREVIATED_INITIALS.match?(@first)
        @first = @first.tr(' ', '').upcase
      else
        @first = prettify(@first)
      end
    end

    if @middle
      if @middle.is_a?(Array)
        prettify_middle_array
      else
        @middle = prettify(@middle)
      end
    end
    @last = prettify(@last) if @last
    @prefix = simple_capitalize(@prefix) if @prefix
    @suffix = clean(@suffix).upcase if @suffix
    @nick = simple_capitalize(@nick) if @nick
  end

  def prettify_middle_array
    if @middle.empty?
      @middle = nil
    else
      keep_periods = (@middle.length > 1)
      @middle = @middle.map { |x| prettify(x, keep_periods: keep_periods) }.join(' ')
    end
  end

  ##
  # Class Methods

  def self.format(str)
    new(str).to_s
  end

  def self.parse_to_hash(str)
    parser = new(str)
    parser.to_h
  end

  def self.parse_to_person(str)
    parser = new(str)
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
          middle_name += " " if middle_name.present?
          middle_name += name_part.titleize
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

  # The SEC doesn't like commas in their names.
  # On Form 3/4 names are LAST FIRST MIDDLE.
  def self.sec_parse(str)
    words = str.split(/ +/)
    unless words.first.last == ','
      words[0] = words[0] + ','
    end
    new words.join(' ')
  end
end
# rubocop:enable Metrics/ClassLength, Metrics/AbcSize, Metrics/MethodLength
# rubocop:enable Metrics/PerceivedComplexity, Style/WordArray
