# frozen_string_literal: true

module ExternalDataset
  class FECContributionGrid < BaseGrid
    scope do
      ExternalDataset::FECContribution.where(fec_year: [2020, 2022])
      # ExternalDataset::FECContribution.all
    end

    filter(:fec_year, :enum, select: %w[2012 2014 2016 2018 2020 2022], multiple: true)
    filter(:transaction_tp, :enum, select: %w[15E 15 24T 22Y 10 24I 15C 11 31 20Y 32], multiple: true)

    column "cmte_id"
    column "amndt_ind"
    column "rpt_tp"
    column "transaction_pgi"
    column "image_num"
    column "transaction_tp"
    column "entity_tp"
    column "name"
    column "city"
    column"state"
    column "zip_code"
    column "employer"
    column "occupation"
    column"transaction_dt"
    column "transaction_amt"
    column  "other_id"
    column "tran_id"
    column"file_num"
    column "memo_cd"
    column "memo_text"
    column"fec_year"
  end
end
