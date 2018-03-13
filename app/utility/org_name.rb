# frozen_string_literal: true

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
    "PA",
    "Chtd",
    "Chartered",
    "Companies",
    "Bancorp",
    "Bancorporation",
    "Ins",
    "Stores",
    "Holdings",
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

  # Set combining common words and suffixes
  ALL_COMMON_WORDS = (COMMON_SUFFIXES + COMMON_WORDS).to_set

  # parsed Org Name
  def self.parse(name)
  end

  def self.strip_name_punctuation(name)
    name
      .gsub(/\.(?!com|net|org|edu)/i, "")
      .gsub(/[,"*]/, "")
      .gsub(/\s{2,}/, " ")
      .strip
  end

  def self.remove_common_suffixes(name)
    common_suffixes.each do |suffix|
      name = name.gsub(/#{suffix}[\.\,]?$/, "")
    end 
    name
  end

  # returns lowercase array of words from a org name that aren't common
  def self.essential_words(name)
    words_to_remove = common_words.uniq.map(&:downcase)    
    name_words = strip_name_punctuation(name).split(/\s+/).map(&:downcase).keep_if do |word|
      word.size > 2
    end
    name_words - words_to_remove
  end
end
