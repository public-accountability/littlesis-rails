# frozen_string_literal: true

module ExternalDataset
  # steps to import NYS Campaign Finance Data
  #   - go to publicreporting.elections.ny.gov and click 'bulk data'
  #   - enter data type = "disclosure report" and "report year" == all
  #   - download all 4 ALL_REPORTS files: state candidate, state committee, county candidate, county committee
  #   - put those files in <Rails-root>/data/external_data/original/nys
  #   - run littlesis data transform nys_disclosures
  #   - this will generate <Rails-root>/data/external_data/csv/nys/nys_disclosures.csv
  #   - in production, move this file to the postgres server at /srv/nys_disclosures.csv
  #   - run littlesis data load nys_disclosures
  class NYSDisclosure < ApplicationRecord
    extend DatasetInterface
    self.primary_key = 'trans_number'
    self.dataset = :nys_disclosures

    @csv_file = ROOT_DIR.join('csv').join('nys_disclosures.csv')

    def self.download
      raise NotImplementedError, "this dataset requires manual downloading via a browser"
    end

    def self.transform
      NYSDisclosureTransformer.run
    end

    def self.load
      directory = if Rails.env.production?
                    '/srv'
                  else
                    '/data/external_data/csv/nys'
                  end

      run_query <<~SQL
        COPY #{table_name} (filer_id, filer_previous_id, cand_comm_name, election_year, election_type, county_desc, filing_abbrev, filing_desc, r_amend, filing_cat_desc, filing_sched_abbrev, filing_sched_desc, loan_lib_number, trans_number, trans_mapping, sched_date, org_date, cntrbr_type_desc, cntrbn_type_desc, transfer_type_desc, receipt_type_desc, receipt_code_desc, purpose_code_desc, r_subcontractor, flng_ent_name, flng_ent_first_name, flng_ent_middle_name, flng_ent_last_name, flng_ent_add1, flng_ent_city, flng_ent_state, flng_ent_zip, flng_ent_country, payment_type_desc, pay_number, owned_amt, org_amt, loan_other_desc, trans_explntn, r_itemized, r_liability, election_year_str, office_desc, district, dist_off_cand_bal_prop)
        FROM '#{directory}/nys_disclosures.csv' WITH CSV;
      SQL
    end
  end
end
