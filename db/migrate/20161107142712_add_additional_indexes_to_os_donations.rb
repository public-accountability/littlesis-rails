class AddAdditionalIndexesToOsDonations < ActiveRecord::Migration
  def change
    add_index :os_donations, :realcode
    add_index :os_donations, :amount
    add_index :os_donations, [:realcode, :amount]
    add_index :os_donations, :state
    add_index :os_donations, :recipid
    add_index :os_donations, [:recipid, :amount]
    add_index :os_donations, :zip
  end
end
