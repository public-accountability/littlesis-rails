# frozen_string_literal: true

module ExternalDataset
  class FECCandidateGrid < BaseGrid
    scope do
      ExternalDataset::FECCandidate.all
    end

    filter(:cand_name, :string, header: 'Candidate Name') do |value|
      where("to_tsvector(cand_name) @@ websearch_to_tsquery(?)", value)
    end

    filter(:cand_id, :string)

    filter(:cand_pty_affiliation, :string, header: 'Party')
    filter(:cand_zip, :string, header: 'Zipcode')

    column "cand_id"
    column "cand_name"
    column "cand_pty_affiliation", order: false
    column "cand_election_yr"
    column "cand_office_st", order: false
    column "cand_office", order: false
    column "cand_office_district", order: false
    column "cand_ici", order: false
    column "cand_status", order: false
    column "cand_pcc"
    column "cand_st1"
    column "cand_st2"
    column "cand_city"
    column "cand_st"
    column "cand_zip"
    column "fec_year"
  end
end
