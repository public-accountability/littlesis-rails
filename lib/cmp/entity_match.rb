# frozen_string_literal: true

module Cmp
  class EntityMatch
    MATCHES = YAML.load_file(Rails.root.join('data', 'cmp_matches.yml'))

    def self.matches
      @matches ||= MATCHES.each_with_object({}) do |h, memo|
        memo.store(h['cmpid'].to_s, h)
      end
    end
  end
end
