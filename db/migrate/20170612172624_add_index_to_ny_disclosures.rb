class AddIndexToNyDisclosures < ActiveRecord::Migration
  def change
    add_index :ny_disclosures, [:filer_id, :report_id, :transaction_id, :schedule_transaction_date, :e_year], name: 'index_filer_report_trans_date_e_year'
  end
end
