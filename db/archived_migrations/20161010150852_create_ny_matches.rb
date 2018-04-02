class CreateNyMatches < ActiveRecord::Migration
  def change
    create_table :ny_matches do |t|
      t.integer :ny_disclosure_id
      t.integer :donor_id
      t.integer :recip_id
      t.integer :relationship_id
      t.integer :matched_by

      t.timestamps
    end
    add_index :ny_matches, :ny_disclosure_id, :unique => true
    add_index :ny_matches, :donor_id
    add_index :ny_matches, :recip_id
    add_index :ny_matches, :relationship_id
    
  end

end
