# frozen_string_literal: true

# === Parses organization names
# The "org" version of NameParser
#
# OrgName.parse returns a +struct+ with 5 components:
#   - original
#   - clean (name without punctuation, downcased)
#   - root (org name without suffix)
#   - suffix (if found)
#   - essential words
#
module OrgName
  COMMON_SUFFIXES = [
    "Inc",
    "Incorporated",
    "Company",
    "Co",
    "Cos",
    "Corp",
    "Corporation",
    "LLP",
    "LLC",
    "LP",
    "PLC",
    "PA",
    "SA",
    "Chtd",
    "GMBH",
    "Chartered",
    "Companies",
    "Bancorp",
    "Bancorporation",
    "Ins",
    "Stores",
    "Holdings",
    "Holdings Limited",
    "Company Limited",
    "Group",
    "Limited",
    "Ltd",
    "Trust",
    "Fund",
    "Solutions",
    "Services",
    "Partners",
    "Enterprises",
    "Committee",
    "Industries",
    "Communications",
    "Companies",
    "Systems",
    "Group"
  ].freeze

  SUFFIX_ACRONYMS = %w[LLP LLC LP PLC PA SA].freeze
  CAPITALIZED_ACRONYMS = %w[PAC NYC].freeze
  ALL_ACRONYMS = (SUFFIX_ACRONYMS + CAPITALIZED_ACRONYMS).freeze

  ACRONYMS_REGEX = Regexp.new "(?<=[ ])(#{ALL_ACRONYMS.join('|')})$", Regexp::IGNORECASE

  SUFFIX_REGEX = Regexp.new "(?<=[ ])(#{COMMON_SUFFIXES.join('|')})(?:[,\.]*)$", Regexp::IGNORECASE

  GRAMMAR_WORDS = %w[And Of The In For].freeze

  COMMON_WORDS = [
    "American",
    "Bank",
    "Financial",
    "Holding",
    "Insurance",
    "International",
    "Equity",
    "Restaurants",
    "Energy",
    "Air",
    "Consulting",
    "Development",
    "Management",
    "Realty",
    "Health",
    "Medical",
    "Center",
    "Corporate",
    "Business",
    "Service",
    "Worldwide",
    "National",
    "Political",
    "Action",
    "PAC",
    "Campaign",
    "Country",
    "First"
  ].freeze

  # Set combining of both common words and suffixes
  ALL_COMMON_WORDS = (GRAMMAR_WORDS + COMMON_SUFFIXES + COMMON_WORDS).map(&:downcase).to_set

  Name = Struct.new(:original, :clean, :root, :suffix, :essential_words)

  # String ---> String
  def self.format(name)
    name
      .split(' ')
      .map(&:capitalize)
      .join(' ')
      .gsub(/\w{3,}-\w{3,}/) { |x| x.split('-').map(&:capitalize).join('-') }
      .gsub(ACRONYMS_REGEX) { |x| x.upcase }
  end

  def self.clean(str)
    parse(str).clean
  end

  # String ---> OrgName::Name
  def self.parse(original_name)
    name = clean(original_name)

    OrgName::Name.new(original_name,
                      name,
                      find_root(name),
                      find_suffix(name),
                      essential_words(name))
  end

  def self.strip_name_punctuation(name)
    name
      .gsub(/\.(?!com|net|org|edu)/i, "")
      .gsub(/[,"*]/, "")
      .gsub(/\s{2,}/, " ")
      .strip
  end

  def self.find_root(name)
    suffix_idx = (name.strip =~ SUFFIX_REGEX)
    return clean(name) if suffix_idx.nil?
    clean name.strip.slice(0, suffix_idx)
  end

  def self.find_suffix(name)
    SUFFIX_REGEX
      .match(strip_name_punctuation(name).strip)
      .try(:[], 1)
  end

  # remove punctuation and downcases the name
  def self.clean(name)
    strip_name_punctuation(name).downcase
  end

  # returns lowercase array of words from a org name that aren't common
  def self.essential_words(name)
    strip_name_punctuation(name)
      .split(/\s+/)
      .keep_if { |word| word.size > 1 }
      .map(&:downcase)
      .to_set
      .difference(Language.schools)
      .difference(ALL_COMMON_WORDS)
      .to_a
  end
end
