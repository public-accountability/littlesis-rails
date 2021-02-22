# frozen_string_literal: true

module ExternalDataset
  class FECLoader
    YEARS = (10..22).to_a.delete_if(&:odd?).map(&:to_s).freeze

    FILENAME_LOOKUP = {
      fec_candidates: 'cn',
      fec_committees: 'cm',
      fec_contributions: 'indiv'
    }.freeze

    COLUMNS_LOOKUP = {
      fec_candidates: %w[cand_id cand_name cand_pty_affiliation cand_election_yr cand_office_st cand_office cand_office_district cand_ici cand_status cand_pcc cand_st1 cand_st2 cand_city cand_st cand_zip fec_year],
      fec_committees: %w[cmte_id cmte_nm tres_nm cmte_st1 cmte_st2 cmte_city cmte_st cmte_zip cmte_dsgn cmte_tp cmte_pty_affiliation cmte_filing_freq org_tp connected_org_nm cand_id fec_year],
      fec_contributions: %w[cmte_id amndt_ind rpt_tp transaction_pgi image_num transaction_tp entity_tp name city state zip_code employer occupation transaction_dt transaction_amt other_id tran_id file_num memo_cd memo_text sub_id fec_year]
    }.freeze

    def self.run(model)
      loop_csv_files(model.dataset_name) do |filepath|
        Rails.logger.info "FEC: Processing #{filepath}"

        model.run_query <<~SQL
          COPY #{model.table_name} (#{COLUMNS_LOOKUP[model.dataset_name].join(',')})
          FROM '#{filepath}' WITH CSV
        SQL
      end
    end

    def self.loop_csv_files(dataset_name)
      YEARS.each do |year|
        basename = FILENAME_LOOKUP.fetch(dataset_name) + year + ".csv"

        rails_path = Rails.root.join('data/fec/csv').join(basename)
        database_path = Pathname.new('/fec').join(basename)

        yield database_path
      end
    end
  end
end
