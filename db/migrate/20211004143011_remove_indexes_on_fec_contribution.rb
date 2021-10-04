class RemoveIndexesOnFECContribution < ActiveRecord::Migration[6.1]
  def change
    remove_index :external_data_fec_contributions, name: 'idx_34370_index_external_data_fec_contributions_on_name'
    remove_index :external_data_fec_contributions, name: 'idx_34370_index_external_data_fec_contributions_on_employer'
    remove_index :external_data_fec_contributions, name: 'idx_34370_index_external_data_fec_contributions_on_transaction_'
  end
end
