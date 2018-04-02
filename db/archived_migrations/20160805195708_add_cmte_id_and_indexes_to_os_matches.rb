class AddCmteIdAndIndexesToOsMatches < ActiveRecord::Migration
  def change
    add_column :os_matches, :cmte_id, :integer
    
    add_index :os_matches, :os_donation_id
    add_index :os_matches, :donor_id
    add_index :os_matches, :recip_id
    add_index :os_matches, :cmte_id
    add_index :os_matches, :relationship_id
    add_index :os_matches, :reference_id
  end
end
