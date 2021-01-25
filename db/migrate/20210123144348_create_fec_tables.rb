class CreateFECTables < ActiveRecord::Migration[6.1]
  def change
    create_table :external_data_fec_candidates do |t|
      t.string :cand_id, null: false
      t.text :cand_name
      t.string :cand_pty_affiliation
      t.integer :cand_election_yr, limit: 1
      t.string :cand_office_st, limit: 2
      t.string  :cand_office, limit: 1
      t.string :cand_office_district, limit: 2
      t.string :cand_ici, limit: 1
      t.string :cand_status, limit: 1
      t.text :cand_pcc
      t.text :cand_st1
      t.text :cand_st2
      t.text :cand_city
      t.string :cand_st, limit: 2
      t.string :cand_zip
      t.integer :fec_year, limit: 2, null: false
    end

    add_index :external_data_fec_candidates, [:cand_id, :fec_year], unique: true

    create_table :external_data_fec_committees do |t|
      t.string :cmte_id, null: false
      t.text :cmte_nm
      t.text :tres_nm
      t.text :cmte_st1
      t.text :cmte_st2
      t.text :cmte_city
      t.string :cmte_st, limit: 2
      t.string :cmte_zip
      t.string :cmte_dsgn, limit: 1
      t.string :cmte_tp, limit: 2
      t.text :cmte_pty_affiliation
      t.string :cmte_filing_freq, limit: 1
      t.string :org_tp, limit: 1
      t.text :connected_org_nm
      t.string :cand_id
      t.integer :fec_year, limit: 2, null: false
    end

    add_index :external_data_fec_committees, [:cmte_id, :fec_year], unique: true

    create_table :external_data_fec_contributions, primary_key: :sub_id do |t|
      t.string :cmte_id, null: false
      t.text :amndt_ind
      t.text :rpt_tp
      t.text :transaction_pgi
      t.string :image_num
      t.string :transaction_tp
      t.string :entity_tp
      t.text :name
      t.text :city
      t.text :state
      t.text :zip_code
      t.text :employer
      t.text :occupation
      t.text :transaction_dt
      t.numeric :transaction_amt # float?
      t.string :other_id
      t.string :tran_id
      t.integer :file_num
      t.text :memo_cd
      t.text :memo_text
      t.integer :fec_year, null: false
    end
  end
end
