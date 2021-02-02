class ExternalDataNYSDisclosures < ActiveRecord::Migration[6.1]
  def change
    create_table(:external_data_nys_disclosures, id: false) do |t|
      t.bigint :filer_id, null: false  #  csv position 1
      t.string :filer_previous_id
      t.string :cand_comm_name
      t.integer :election_year
      t.string :election_type
      t.string :county_desc
      t.string :filing_abbrev, limit: 1
      t.string :filing_desc
      t.string :filing_cat_desc # csv position 10
      t.string :filing_sched_abbrev
      t.string :filing_sched_desc
      t.string :loan_lib_number
      t.string :trans_number, null: false
      t.string :trans_mapping
      t.datetime :sched_date
      t.datetime :org_date # csv position 17
      t.string :cntrbr_type_desc
      t.string :cntrbn_type_desc
      t.string :transfer_type_desc
      t.string :receipt_type_desc
      t.string :receipt_code_desc
      t.string :purpose_code_desc
      t.string :r_subcontractor
      t.string :flng_ent_name
      t.string :flng_ent_first_name
      t.string :flng_ent_middle_name
      t.string :flng_ent_last_name
      t.string :flng_ent_add1
      t.string :flng_ent_city # csv position 30
      t.string :flng_ent_state
      t.string :flng_ent_zip
      t.string :flng_ent_country
      t.string :payment_type_desc
      t.string :pay_number
      t.float :owned_amt
      t.float :org_amt
      t.string :loan_other_desc
      t.string :trans_explntn
      t.string :r_itemized, limit: 1 # csv position 40
      t.string :r_liability, limit: 1
      t.string :election_year_str
      t.string :office_desc
      t.string :district
      t.text :dist_off_cand_bal_prop

      t.index :trans_number, unique: true
      t.index :filer_id
      t.index :org_amt
      t.index :flng_ent_name, type: :fulltext
      t.index :flng_ent_last_name, type: :fulltext
    end
  end
end
