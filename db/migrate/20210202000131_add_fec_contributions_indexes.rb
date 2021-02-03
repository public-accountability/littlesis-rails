class AddFECContributionsIndexes < ActiveRecord::Migration[6.1]
  def change
    add_index :external_data_fec_contributions, :cmte_id
    add_index :external_data_fec_contributions, :name, type: :fulltext
    add_index :external_data_fec_contributions, :employer, type: :fulltext
    add_index :external_data_fec_contributions, :transaction_amt
  end
end
