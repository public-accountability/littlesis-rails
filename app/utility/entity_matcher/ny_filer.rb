# frozen_string_literal: true

module EntityMatcher
  class NyFiler
    PREFIXES_TO_REMOVE = [
      'FRIENDS OF',
      'FRIENDS 4',
      'REAL FRIENDS OF',
      'COMMITTEE TO RE-ELECT',
      'COMMITTEE TO ELECT',
      'FRIENDS TO ELECT',
      'COMMITTEE FOR',
      'CITIZENS FOR',
      'THE CAMPAIGN FOR',
      'CAMPAIGN TO ELECT',
      'NEW YORKERS FOR',
      'PEOPLE FOR',
      'WIN WITH',
      'TAXPAYERS FOR',
      'CITIZENS TO ELECT',
      'CITIZENS COMM FOR THE ELECTION OF',
      'COMM FOR SENATOR',
      'LABOR COMM FOR'
    ].freeze

    PREFIX_REGEX = Regexp.new PREFIXES_TO_REMOVE.join('|')
    PARENTHESES_REGEX = Regexp.new '(.*)\(.*\)(.*)'
    FOR_REGEX = Regexp.new '(.*)(?:FOR|4).*$'
    COUNTY_FOR = Regexp.new '.*COUNTY (?:FOR|4)(.*)$'
    YEAR_REGEX = Regexp.new "(IN)? '\\d{2}"
    NUMBER_REGEX = Regexp.new '\d{2,}'

    # String ---> String
    def self.extract_name_from(committee_name)
      committee_name
        .gsub(PREFIX_REGEX, '')
        .gsub(PARENTHESES_REGEX, '\1\2')
        .gsub(COUNTY_FOR, '\1')
        .gsub(FOR_REGEX, '\1')
        .gsub(YEAR_REGEX, '')
        .gsub(NUMBER_REGEX, '')
        .strip
    end

    # NyFiler ---> Entity | nil
    def self.matches(ny_filer)
      if ny_filer.match_to_person?
        EntityMatcher
          .find_matches_for_person(extract_name_from(ny_filer.name))
          .results
      else
        EntityMatcher
          .find_matches_for_org(ny_filer.name)
          .results
      end
    end
  end
end
