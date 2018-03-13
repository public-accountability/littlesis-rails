# frozen_string_literal: true

# === Parses organization names
# The "org" version of NameParser
#
# OrgName.parse returns a +struct+ with 4 components:
#   - original
#   - clean (name without punctuation or suffix)
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

  SUFFIX_REGEX = Regexp.new "(?<=[ ])(#{COMMON_SUFFIXES.join('|')})(?:[,\.]*)$", Regexp::IGNORECASE

  GRAMMAR_WORDS = ['And', 'Of', 'The'].freeze

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

  Name = Struct.new(:original, :clean, :suffix, :essential_words)

  # String ---> OrgName::Name
  def self.parse(name)
    OrgName::Name.new(name, clean(name), find_suffix(name), essential_words(name))
  end

  def self.strip_name_punctuation(name)
    name
      .gsub(/\.(?!com|net|org|edu)/i, "")
      .gsub(/[,"*]/, "")
      .gsub(/\s{2,}/, " ")
      .strip
  end

  def self.find_suffix(name)
    SUFFIX_REGEX.match(name.strip).try(:[], 1)
  end

  # remove punctuation, common suffix, and downcases the name
  def self.clean(name)
    strip_name_punctuation(name)
      .gsub(SUFFIX_REGEX, '')
      .strip
      .downcase
  end

  # returns lowercase array of words from a org name that aren't common
  def self.essential_words(name)
    strip_name_punctuation(name)
      .split(/\s+/)
      .keep_if { |word| word.size > 2 }
      .map(&:downcase)
      .to_set
      .difference(ALL_COMMON_WORDS)
      .to_a
  end
end
