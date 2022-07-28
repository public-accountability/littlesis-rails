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

    UNIQUE_KEY_LOOKUP = {
      fec_candidates: 'cand_id',
      fec_committees: 'cmte_id',
      fec_contributions: 'sub_id'
    }.freeze

    def self.run(model)
      loop_csv_files(model.dataset_name) do |filepath|
        Rails.logger.info "FEC: Processing #{filepath}"

        model.run_query <<~SQL.squish
          COPY #{model.table_name} (#{COLUMNS_LOOKUP[model.dataset_name].join(',')})
          FROM '#{filepath}' WITH CSV
        SQL
      end
    end

    # This can takes more than 8 hours
    def self.create_update_files
      [FECCandidate, FECCommittee, FECContribution].each do |model|
        create_update_file(model, '22')
      end
    end

    def self.load_update_files
      [FECCandidate, FECCommittee, FECContribution].each do |model|
        filepath = csv_path_root.join "#{FILENAME_LOOKUP[model.dataset_name]}22_update.csv"

        model.run_query <<~SQL.squish
          COPY #{model.table_name} (#{COLUMNS_LOOKUP[model.dataset_name].join(',')})
          FROM '#{filepath}' WITH CSV
        SQL
      end
    end

    # .run uses COPY to directly load the entire file, but we sometimes want to re-download
    # the latest files and then only copy into postgres the new rows
    # year is a 2-digit string, i.e. 22
    def self.create_update_file(model, year)
      outfile = csv_path_root.join(FILENAME_LOOKUP.fetch(model.dataset_name) + year + "_update.csv")
      csvfile = csv_path_root.join(FILENAME_LOOKUP.fetch(model.dataset_name) + year + ".csv")
      fec_year = "20#{year}".to_i
      key = UNIQUE_KEY_LOOKUP.fetch(model.dataset_name)

      File.open(outfile, 'w') do |update_file|
        File.foreach(csvfile) do |line|
          row = COLUMNS_LOOKUP[model.dataset_name].zip(CSV.parse_line(line)).to_h

          unless model.exists?('fec_year' => fec_year, key => row.fetch(key))
            update_file.write line
          end
        end
      end
    end

    def self.loop_csv_files(dataset_name)
      YEARS.each do |year|
        yield csv_path_root.join(FILENAME_LOOKUP.fetch(dataset_name) + year + ".csv")
      end
    end

    def self.csv_path_root
      @csv_path_root ||= if Rails.env.production?
                           Pathname.new('/var/lib/littlesis/fec')
                         elsif Rails.env.development?
                           Rails.root.join('data/fec/csv')
                         # Pathname.new('/data/fec/csv')
                         else
                           Rails.root.join('data/fec/csv')
                         end
    end
  end
end
