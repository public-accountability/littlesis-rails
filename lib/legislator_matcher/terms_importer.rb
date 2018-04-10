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
      return distill(terms.drop(1), Array.wrap(terms.first.deep_dup)) if distinct_terms.empty?

      if within_one_month(terms.first['start'], distinct_terms.last['end'])
        if equivalent?(terms.first, distinct_terms.last)
          distinct_terms.last['end'] = terms.first['end'].clone
          return distill terms.drop(1), distinct_terms
        end
      end
      return distill terms.drop(1), distinct_terms.push(terms.first.deep_dup)
    end

    # defines methods: rep_terms, distilled_rep_terms, sen_terms, distilled_sen_terms
    %w[rep sen].each do |type|
      define_method "#{type}_terms" do
        legislator['terms'].select { |t| t['type'] == type }.sort_by { |t| t['start'] }
      end

      define_method "distilled_#{type}_terms" do
        distill public_send("#{type}_terms")
      end
    end

    private

    # str, str --> boolean
    def within_one_month(date_one, date_two)
      (Date.parse(date_one) - Date.parse(date_two)).to_i.abs <= 30
    end

    def equivalent?(a, b)
      a['state'].eql?(b['state']) && a['district'].eql?(b['district']) && a['party'].eql?(b['party'])
    end
  end
end


