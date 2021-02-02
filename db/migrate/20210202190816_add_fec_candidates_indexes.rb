class AddFECCandidatesIndexes < ActiveRecord::Migration[6.1]
  def change
    add_index :external_data_fec_candidates, :cand_name, type: :fulltext
    add_index :external_data_fec_candidates, :cand_pty_affiliation
  end
end
