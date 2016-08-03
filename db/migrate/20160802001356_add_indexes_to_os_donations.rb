class AddIndexesToOsDonations < ActiveRecord::Migration
  def change
    add_index :os_donations, :fectransid
    add_index :os_donations, :cycle
    add_index :os_donations, :microfilm
    add_index :os_donations, :date
    add_index :os_donations, :contribid
    add_index :os_donations, [:fectransid, :cycle]
    add_index :os_donations, [:name_last, :name_first]
  end
end
