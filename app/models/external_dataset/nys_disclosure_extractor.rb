# frozen_string_literal: true

# 1 filer_id
# 2 filer_previous_id
# 3 cand_comm_name
# 4 election_year
# 5 election_type
# 6 county_desc
# 7 filing_abbrev
# 8 filing_desc
# 9 r_amend
# 10 filing_cat_desc
# 11 filing_sched_abbrev
# 12 filing_sched_desc
# 13 loan_lib_number
# 14 trans_number
# 15 trans_mapping
# 16 sched_date
# 17 org_date
# 18 cntrbr_type_desc
# 19 cntrbn_type_desc
# 20 transfer_type_desc
# 21 receipt_type_desc
# 22 receipt_code_desc
# 23 purpose_code_desc
# 24 r_subcontractor
# 25 flng_ent_name
# 26 flng_ent_first_name
# 27 flng_ent_middle_name
# 28 flng_ent_last_name
# 29 flng_ent_add1
# There appears to be an extra, blank field here
# 30 flng_ent_city
# 31 flng_ent_state
# 32 flng_ent_zip
# 33 flng_ent_country
# 34 payment_type_desc
# 35 pay_number
# 36 owned_amt
# 37 org_amt
# 38 loan_other_desc
# 39 trans_explntn
# 40 r_itemized
# 41 r_liability
# 42 election_year_str
# 43 office_desc
# 44 district
# 45 dist_off_cand_bal_prop

module ExternalDataset
  class NYSDisclosureExtractor
    FILES = [
      %w[ALL_REPORTS_CountyCandidate COUNTY_CANDIDATE],
      %w[ALL_REPORTS_CountyCommittee COUNTY_COMMITTEE],
      %w[ALL_REPORTS_StateCandidate STATE_CANDIDATE],
      %w[ALL_REPORTS_StateCommittee STATE_COMMITTEE]
    ].freeze

    TO_CSV_PATH = ->(x) { ROOT_DIR.join('csv/nys', "#{x}_out.csv") }

    def self.run
      FileUtils.mkdir_p ROOT_DIR.join('csv/nys')

      FILES.each do |(outer, inner)|
        outer_zip = ROOT_DIR.join('original/nys', "#{outer}.zip")
        inner_zip = ROOT_DIR.join('original/nys', "#{inner}.zip")
        original_csv = ROOT_DIR.join('original/nys', "#{inner}.csv")
        output_csv = ROOT_DIR.join('csv/nys', "#{inner}.csv")
        system "unzip -o #{outer_zip} #{inner}.zip -d #{ROOT_DIR.join('original/nys')}", exception: true
        system "unzip -o #{inner_zip} #{inner}.csv -d #{ROOT_DIR.join('original/nys')}", exception: true
        system "tr -d '\\000' < #{original_csv} | iconv -f iso-8859-1 -t utf8  > #{output_csv}", exception: true
        system "csvclean #{output_csv}", exception: true, chdir: ROOT_DIR.join('csv/nys').to_s
      end

      CSV.open(ROOT_DIR.join('csv/nys/nys_disclosures.csv'), 'w') do |destination|
        FILES.map(&:second).map(&TO_CSV_PATH).each do |csv_filepath|
          CSV.foreach(csv_filepath) do |row|
            destination.add_row row[0..28] + row[30..]
          end
        end
      end
    end
  end
end
