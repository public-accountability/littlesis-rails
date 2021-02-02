class AddFECCommitteesIndexes < ActiveRecord::Migration[6.1]
  def change
    add_index :external_data_fec_committees, :cmte_nm, type: :fulltext
    add_index :external_data_fec_committees, :connected_org_nm, type: :fulltext
    add_index :external_data_fec_committees, :cmte_pty_affiliation
  end
end
