class CreateOsMatches < ActiveRecord::Migration
  def change
    create_table :os_matches do |t|
      t.integer :os_donation_id, index: true, null: false
      t.integer :donation_id, index: true
      t.integer :donor_id, index: true, null: false
      t.integer :recip_id, index: true
      t.integer :matched_by
      t.boolean :is_deleted, default: false, null: false
      t.timestamps
    end
  end
end
