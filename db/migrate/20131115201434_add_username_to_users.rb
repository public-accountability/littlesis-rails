class AddUsernameToUsers < ActiveRecord::Migration
  def change
  	change_table :users do |t|
  		t.string :username, null: false
  	end
  end
end
