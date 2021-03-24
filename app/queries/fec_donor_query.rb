# frozen_string_literal: true

module FECDonorQuery
  def self.run(query)
    search_terms = Array.wrap(query).map(&:upcase)

    ExternalDataset::FECContribution
      .left_outer_joins(:fec_match)
      .where('fec_matches.id is null') # only include unmatched donations
      .where(name: search_terms)
  end
end
