class OrgName
  def self.common_suffixes
    [
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
		]
  end
  
  def self.common_words
    common_suffixes + [
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
		]
  end
    
  def self.strip_name_punctuation(name)
    name = name.gsub(/\.(?!com|net|org|edu)/i, "")
    name = name.gsub(/[,"*]/, "")
    name = name.gsub(/\s{2,}/, "").strip
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