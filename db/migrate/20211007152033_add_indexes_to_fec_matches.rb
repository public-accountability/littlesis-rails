class AddIndexesToFECMatches < ActiveRecord::Migration[6.1]
  def change
    add_index :fec_matches, :sub_id, unique: true
    add_index :fec_matches, :donor_id
    add_index :fec_matches, :recipient_id
    add_index :fec_matches, :candidate_id
    add_index :fec_matches, :committee_relationship_id
  end
end
