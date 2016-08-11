class ChangeLengthOfMicrofilmColumnOnOsDonations < ActiveRecord::Migration
  def up
    change_column :os_donations, :microfilm, :string, limit: 30
  end
  def down
    change_column :os_donations, :microfilm, :string, limit: 11
  end
end
