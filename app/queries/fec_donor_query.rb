# frozen_string_literal: true

module FECDonorQuery
  def self.run(query)
    ExternalDataset::FECContribution
      .left_outer_joins(:fec_match)
      .where("to_tsvector(name) @@ websearch_to_tsquery(?)", query.upcase)
    # .where('fec_matches.id is null') # only include unmatched donations
  end
end
