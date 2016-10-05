class CreateNyDisclosures < ActiveRecord::Migration
  def change
    # Many of the column names have been changed slightly from the BOE's data to improve their readability.
    #    Original           | Ours
    # ----------------------|--------
    # FREPORT_ID            | report_id
    # T3_TRID               | transaction_id
    # DATE1_10              | schedule_transaction_date
    # DATE2_12              | original_date
    # CONTRIB_CODE_20       | contrib_code
    # CONTRIB_TYPE_CODE_25  | contrib_type_code
    # CORP_30               | corp_name
    # FIRST_NAME_40         | first_name
    # MID_INIT_42           | mid_init
    # LAST_NAME_44          | last_name
    # ADDR_1_50             | address
    # CITY_52               | city
    # STATE_54              | state
    # ZIP_56                | zip
    # CHECK_NO_60           | check_number
    # CHECK_DATE_62         | check_date
    # AMOUNT_70             | amount1
    # AMOUNT2_72            | amount2
    # DESCRIPTION_80        | description
    # OTHER_RECPT_CODE_90   | other_recpt_code
    # PURPOSE_CODE1_100     | purpose_code1
    # PURPOSE_CODE2_102     | purpose_code2
    # EXPLANATION_110       | explanation
    # XFER_TYPE_120         | transfer_type
    # CHKBOX_130            | bank_loan_check_box
    # CREREC_UID            | crerec_uid
    # CREREC_DATE           | crerec_date
    create_table :ny_disclosures do |t|
      t.string :filer_id, limit: 10, null: false
      t.string :report_id
      t.string :transaction_code, limit: 1,  null: false
      t.string :e_year, limit: 4, null: false
      t.integer :transaction_id, null: false
      t.date :schedule_transaction_date
      t.date :original_date
      t.string :contrib_code, limit: 4
      t.string :contrib_type_code, limit: 1
      t.string :corp_name
      t.string :first_name
      t.string :mid_init
      t.string :last_name
      t.string :address
      t.string :city
      t.string :state, limit: 2
      t.string :zip, limit: 5
      t.string :check_number
      t.date :check_date
      t.float :amount1
      t.float :amount2
      t.string :description
      t.string :other_recpt_code
      t.string :purpose_code1
      t.string :purpose_code2
      t.string :explanation
      t.string :transfer_type, limit: 1
      t.string :bank_loan_check_box, limit: 1
      t.string :crerec_uid
      t.datetime :crerec_date
      
      t.timestamps
    end
    add_index :ny_disclosures, :filer_id
    add_index :ny_disclosures, :e_year
    add_index :ny_disclosures, :contrib_code
    add_index :ny_disclosures, :original_date
  end
end
