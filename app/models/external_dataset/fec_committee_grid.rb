# frozen_string_literal: true

module ExternalDataset
  class FECCommitteeGrid < BaseGrid
    scope do
      ExternalDataset::FECCommittee.all
    end

    filter(:name, :string)
    filter(:transactino_dt, :date)
    filter(:transaction_amt, :number)


    column 'cmte_id'
    column 'amndt_ind'
    column 'rpt_tp'
    column 'transaction_pgi'
    column 'image_num'
    column 'transaction_tp'
    column 'entity_tp'
    column 'name'
    column 'city'
    column 'state'
    column 'zip_code'
    column 'employer'
    column 'occupation'
    column 'transaction_dt'
    column 'transaction_amt'
    column 'other_id'
    column 'tran_id'
    column 'file_num'
    column 'memo_cd'
    column 'memo_text'
    column 'fec_year'
  end
end
