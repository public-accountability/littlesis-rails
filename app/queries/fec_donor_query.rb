# frozen_string_literal: true

module FECDonorQuery
  # str or entity --> [Donors]
  def self.run(search_term, matched: false)
    query = if search_term.is_a?(Entity)
              LsSearch.generate_search_terms(search_term)
            else
              search_term
            end

    ExternalData.search(query, {
                          indices: ['external_data_fec_donor_core'],
                          per_page: 1_000,
                          with: { matched: matched }
                        })
  end
end
