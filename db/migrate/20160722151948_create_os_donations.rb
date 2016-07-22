class CreateOsDonations < ActiveRecord::Migration
  def change
    create_table :os_donations do |t|
      t.string :cycle, limit: 3
      t.string :fectransid, limit: 19
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
      t.string :recipcode, limit: 2
      t.string :transactiontype, limit: 3
      t.string :cmteid, limit: 9
      t.string :otherid, limit: 9
      t.string :gender, limit: 1
      t.string :microfilm, limit: 11
      t.string :occupation
      t.string :employer
      t.string :source, limit: 5
      
      t.timestamps
    end
  end
end
