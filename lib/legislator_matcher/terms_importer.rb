# frozen_string_literal: true

class LegislatorMatcher
  class TermsImporter
    attr_internal :legislator

    def initialize(legislator)
      @_legislator = legislator
    end

    def import!
    end

    def distill(terms, distinct_terms = [])
      return distinct_terms if terms.empty?
      return distill(terms.drop(1), Array.wrap(terms.first)) if distinct_terms.empty?

      if (Date.parse(terms.first['start']) - Date.parse(distinct_terms.last['end'])) == 1
        if terms.first['state'].eql?(distinct_terms.last['state']) && terms.first['district'].eql?(distinct_terms.last['district'])
          distinct_terms.last['end'] = terms.first['end']
          return distill terms.drop(1), distinct_terms
        end
      end
      return distill terms.drop(1), distinct_terms.push(terms.first)
    end 

    def rep_terms
      legislator['terms'].select { |t| t['type'] == 'rep' }.sort_by { |t| t['start'] }
    end

    def sen_terms
      legislator['terms'].select { |t| t['type'] == 'sen' }.sort_by { |t| t['start'] }
    end
  end
end
