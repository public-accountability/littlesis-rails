# frozen_string_literal: true

module ExternalDataset
  class NYSDisclosureGrid < BaseGrid
    scope do
      ExternalDataset::NYSDisclosure.order(trans_number: :desc)
    end

    filter(:flng_ent_name, :string, header: 'Name') do |value|
      where("MATCH (flng_ent_name) AGAINST (? IN BOOLEAN MODE)", value)
    end

    filter(:flng_ent_last_name, :string, header: 'Last Name') do |value|
      where("MATCH (flng_ent_last_name) AGAINST (? IN BOOLEAN MODE)", value)
    end

    filter(:filing_sched_abbrev, :enum, select: %w[A B C D E F G H I J K L M N O P Q R], header: 'Schedule')

    filter(:org_amt, :float)

    column "filer_id", order: false
    column "filer_previous_id", order: false
    column "cand_comm_name"
    column "election_year"
    column "election_type"
    column "county_desc"
    column "filing_abbrev"
    column "filing_desc"
    column "filing_cat_desc"
    column "filing_sched_abbrev"
    column "filing_sched_desc"
    column "loan_lib_number"
    column "trans_number"
    column "trans_mapping"
    column "sched_date"
    column "org_date"
    column "cntrbr_type_desc", order: false
    column "cntrbn_type_desc", order: false
    column "transfer_type_desc", order: false
    column "receipt_type_desc", order: false
    column "receipt_code_desc", order: false
    column "purpose_code_desc", order: false
    column "r_subcontractor", order: false
    column "flng_ent_name"
    column "flng_ent_first_name"
    column "flng_ent_middle_name", order: false
    column "flng_ent_last_name"
    column "flng_ent_add1"
    column "flng_ent_city"
    column "flng_ent_state"
    column "flng_ent_zip"
    column "flng_ent_country"
    column "payment_type_desc", order: false
    column "pay_number"
    column "owned_amt"
    column "org_amt"
    column "loan_other_desc", order: false
    column "trans_explntn", order: false
    column "r_itemized", order: false
    column "r_liability", order: false
    column "election_year_str"
    column "office_desc"
    column "district"
    column "dist_off_cand_bal_prop", order: false
  end
end
