# frozen_string_literal: true

module ExternalDataset
  class FECCommitteeGrid < BaseGrid
    scope do
      ExternalDataset::FECCommittee.all
    end

    filter(:cmte_nm, :string, header: 'Committee Name') do |value|
      where("to_tsvector(cmte_nm) @@ websearch_to_tsquery(?)", value)
    end

    filter(:connected_org_nm, :string, header: 'Connected Org Name') do |value|
      where("to_tsvector(connected_org_nm) @@ websearch_to_tsquery(?)", value)
    end

    filter(:cand_id, :string, header: 'Candidate ID')


    filter(:cmte_pty_affiliation, :string, header: "Party")
    filter(:cmte_zip, :string, header: 'Zipcode')

    column "cmte_id"
    column "cmte_nm"
    column "tres_nm"
    column "cmte_city"
    column "cmte_st"
    column "cmte_zip"
    column "cmte_dsgn"
    column "cmte_tp"
    column "cmte_pty_affiliation"
    column "cmte_filing_freq"
    column "org_tp"
    column "connected_org_nm"
    column "cand_id"
    column "fec_year"
  end
end
