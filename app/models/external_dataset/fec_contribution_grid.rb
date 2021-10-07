# frozen_string_literal: true

module ExternalDataset
  class FECContributionGrid < BaseGrid
    self.batch_size = nil

    scope do
      ExternalDataset::FECContribution
    end

    TRANSACTION_TYPE_OPTIONS = [
      ['Super PAC (10)', '10'],
      ['Committee (15)', '15'],
      ['From Candidate (15C)', '15C'],
      ['Earmarked (15E)', '15E'],
      ['Inaugural (13)', '13'],
      ['Election Recount Disbursement', '24R']
    ].freeze

    # %w[15E 15 24T 22Y 10 24I 15C 11 31 20Y 32]

    filter(:fec_year, :enum, select: %w[2022 2020 2018 2016 2014 2012], include_blank: false, default: '2020', header: 'Year')
    filter(:transaction_tp, :enum, select: TRANSACTION_TYPE_OPTIONS, multiple: true, header: 'Transaction Type')
    filter(:cmte_id, header: 'Committee ID')

    filter(:name, :string) do |value|
      where("name_tsvector @@ websearch_to_tsquery(?)", value)
    end

    filter(:employer, :string) do |value|
      where("to_tsvector(employer) @@ websearch_to_tsquery(?)", value)
    end

    filter(:zip_code, :string)

    filter(:city, :string) do |value|
      where(city: value.upcase)
    end

    filter(:transaction_amt, :integer, header: 'Minimum value') do |value|
      where('transaction_amt >= ?', value)
    end

    column("cmte_id", header: "Committee") do |record|
      format(record.cmte_id) do |_|
        record.fec_committee.display_name
      end
    end

    # column "amndt_ind"
    column "rpt_tp", header: 'Report Type', order: false
    # column "transaction_pgi"
    # column "image_num"
    column "transaction_tp", header: 'Transaction Type'
    # column "entity_tp"
    column "name"
    column "city", order: false
    column "state"
    column "zip_code"
    column "employer", order: false
    column "occupation", order: false
    column "date", header: 'Date'
    column("transaction_amt", header: 'Amount') { |record| ActiveSupport::NumberHelper.number_to_delimited(record.transaction_amt) }
    # column  "other_id"
    # column "tran_id", header: 'TransactionID'
    column("file_num", header: 'Filing') do |record|
      format(record.file_num) do |val|
        link_to val, record.reference_url, target: '_blank', rel: 'noopener'
      end
    end
    column "memo_cd", order: false
    column "memo_text", order: false
    column "fec_year", header: 'Year'
  end
end
