# frozen_string_literal: true

class Language
  AN_REQUIRING_PATTERNS = /^([aefhilmnorsx]$|hono|honest|hour|heir|[aeiou]|8|11)/i

  REGIONS = [
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
  ].freeze

  GEOGRAPHY = [
    'Southern',
    'Northern',
    'Western',
    'Eastern'
  ].freeze

  SCHOOLS = [
    'School',
    'University',
    'College',
    'Department',
    'Faculty',
    'Master',
    'Bachelor',
    'Doctorate',
    'State'
  ].freeze

  BUSINESS = [
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
  ].freeze

  def self.schools
    @schools ||= SCHOOLS.map(&:downcase).to_set.freeze
  end

  # Adds a or an to the provided word
  # simplied from https://github.com/rossmeissl/indefinite_article/blob/master/lib/indefinite_article.rb
  def self.with_indefinite_article(word)
    AN_REQUIRING_PATTERNS.match?(word) ? "an #{word}" : "a #{word}"
  end
end
