# frozen_string_literal: true

module ExternalDataset
  class FECContributionGrid < BaseGrid
    scope do
      ExternalDataset::FECContribution.all
    end

    filter(:fec_year, :enum, select: %w[2022 2020 2018 2016 2014 2012], include_blank: false, default: '2020')
    filter(:transaction_tp, :enum, select: %w[15E 15 24T 22Y 10 24I 15C 11 31 20Y 32], multiple: true)
    filter(:cmte_id, header: 'Committee ID')
    filter(:name, :string) { |value| where("MATCH (name) AGAINST (? IN BOOLEAN MODE)", value) }
    filter(:employer, :string) { |value| where("MATCH (employer) AGAINST (? IN BOOLEAN MODE)", value) }
    filter(:zip_code, :string)

    filter(:transaction_amt, :integer, header: 'Minimum value') do |value|
      where('transaction_amt >= ?', value)
    end

    column "cmte_id" do |record|
      format(record.cmte_id) do |_|
        record.fec_committee.display_name
      end
    end

    column "amndt_ind"
    column "rpt_tp"
    # column "transaction_pgi"
    # column "image_num"
    column "transaction_tp"
    # column "entity_tp"
    column "name"
    column "city"
    column "state"
    column "zip_code"
    column "employer"
    column "occupation"
    column "transaction_dt"
    column("transaction_amt") { |record| ActiveSupport::NumberHelper.number_to_delimited(record.transaction_amt) }
    column  "other_id"
    column "tran_id"
    column "file_num"
    column "memo_cd"
    column "memo_text"
    column "fec_year"
  end
end
