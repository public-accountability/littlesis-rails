class CreateOsDonations < ActiveRecord::Migration
  def change
    create_table :os_donations do |t|
      ## columns in raw OpenSecrets data ##
      t.string :cycle, limit: 4, null: false
      t.string :fectransid, limit: 19, null: false
      t.string :contribid, limit: 12
      t.string :contrib
      t.string :recipid, limit: 9
      t.string :orgname
      t.string :ultorg
      t.string :realcode, limit: 5
      t.date :date
      t.integer :amount
      t.string :street
      t.string :city
      t.string :state, limit: 2
      t.string :zip, limit:5
      t.string :recipcode, limit: 2
      t.string :transactiontype, limit: 3
      t.string :cmteid, limit: 9
      t.string :otherid, limit: 9
      t.string :gender, limit: 1
      t.string :microfilm, limit: 11
      t.string :occupation
      t.string :employer
      t.string :source, limit: 5
      
      ### combined cycle & fec ids ##
      t.string :fec_cycle_id, limit: 24, null: false
      
      ## parsed name columns ##
      t.string :name_last
      t.string :name_first
      t.string :name_middle
      t.string :name_suffix
      t.string :name_prefix
      
      t.timestamps
    end
  end
end
