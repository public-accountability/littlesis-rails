class RenameMembershipElectedTermCol < ActiveRecord::Migration[6.0]
  def change
    remove_column :membership, :elected_term
    rename_column :membership, :elected_term_hash, :elected_term
  end
end
