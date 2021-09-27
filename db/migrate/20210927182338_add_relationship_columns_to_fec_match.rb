class AddRelationshipColumnsToFECMatch < ActiveRecord::Migration[6.1]
  def change
    change_column_null :fec_matches, :recipient_id, false
    add_column :fec_matches, :committee_relationship_id, :bigint, null: false
    add_column :fec_matches, :candidate_relationship_id, :bigint, null: true
  end
end
