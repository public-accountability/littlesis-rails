class ExternalDataNYSDisclosures < ActiveRecord::Migration[6.1]
  def change
    create_table(:external_data_nys_disclosures, id: false) do |t|
      t.string :filer_id, null: false, index: true
      t.string :freport_id
      t.string :transaction_code
      t.string :e_year
      t.string :t3_trid
      t.date :date1_10, index: true
      t.date :date2_12
      t.string :contrib_code_20
      t.string :contrib_type_code_25
      t.string :corp_30
      t.string :first_name_40
      t.string :mid_init_42
      t.string :last_name_44
      t.string :addr_1_50
      t.string :city_52
      t.string :state_54
      t.string :zip_56
      t.string :check_no_60
      t.string :check_date_62
      t.float :amount_70
      t.float :amount2_72
      t.string :description_80
      t.string :other_recpt_code_90
      t.string :purpose_code1_100
      t.string :purpose_code2_1
      t.string :explanation_110
      t.string :xfer_type_120
      t.string :chkbox_130
      t.string :crerec_uid
      t.datetime :crerec_date
      t.string :dataset_id, null: false, unique: true, index: true
    end

    execute "ALTER TABLE external_data_nys_disclosures ADD PRIMARY KEY (dataset_id)"
  end
end
