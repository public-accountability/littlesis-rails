class CreateIndexesOnFECContribution < ActiveRecord::Migration[6.1]
  def change
    remove_index :external_data_fec_contributions, name: 'idx_34370_index_external_data_fec_contributions_on_fec_year_and'
    add_index :external_data_fec_contributions, :fec_year
    add_index :external_data_fec_contributions, :date
    add_index :external_data_fec_contributions, :transaction_tp
  end
end
