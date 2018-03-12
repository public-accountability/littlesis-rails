# NOTE (Mon 12 Mar 2018)
# This class appears to only be used by twitter.rake,
# a task not run in **YEARS**
class OrgNames
  
  def self.get_name_words_from_text(text)
    # remove punctuation
    words = text.split(/\s+/).flatten.join(' ').gsub(/[.,;?!]/, '').split(/\s+/)

    # remove blank items and initials
    words.reject! { |word| word.length < 2 }

    # only unique capitalized words
    words = words.select { |word| word.upcase[0] == word[0] }.uniq
  end

  def self.remove_common_words(given_words)
    filtered = given_words

    words_to_remove = [
      BUSINESS_WORDS,
      SCHOOL_WORDS,
      GEO_WORDS,
      GRAMMAR_WORDS,
      OrgName.common_words
    ].flatten

    words_to_remove.each do |word|
      filtered = filtered.join(' ').gsub(/(^| )#{Regexp.quote(word)}( |$)/i, '\1\2').split(/\s+/)
    end

    filtered
  end

  BUSINESS_WORDS = [
    'American',
    'Board',
    'Directors',
    'Corp',
    'Company',
    'Inc',
    'CEO',
    'Chief',
    'President',
    'Executive',
    'Director',
    'Vice',
    'Chair',
    'Chairman',
    'COO',
    'CFO',
    'EVP',
    'SVP',
    'Treasurer',
    'Secretary',
    'Controller',
    'Committee',
    'LLC',
    'LLP',
    'Corporation',
    'Co',
    'Fund',
    'Bank',
    'Industries',
    'Financial',
    'Bancorp',
    'Holding',
    'Holdings',
    'Insurance',
    'International',
    'Trust',
    'Equity',
    'Stores',
    'Companies',
    'Restaurants',
    'Communications',
    'Enterprises',
    'Energy',
    'Air',
    'Systems',
    'Consulting',
    'Partners',
    'Limited',
    'Ltd',
    'Development',
    'Management',
    'Realty',
    'Health',
    'Medical',
    'Center',
    'Engineering',
    'Corporate',
    'Business',
    'Senior',
    'Group',
    'Solutions',
    'Service',
    'Worldwide'
  ]

  SCHOOL_WORDS = [
    'School',
    'University',
    'College',
    'Department',
    'Faculty',
    'Master',
    'Bachelor',
    'Doctorate',
    'State'
  ]

  GEO_WORDS = [
    'Asia',
    'Africa',
    'North America',
    'South America',
    'Europe',
    'Middle East',
    'East Asia',
    'Western Europe',
    'Eastern Europe',
    'Near East',
    'Asia Pacific',
    'South Pacific',
    'America'
  ]

  GRAMMAR_WORDS = [
    'And',
    'Of',
    'The'
  ]

end
