class AddNewUserIdToNote < ActiveRecord::Migration
  def change
  	change_table :note do |t|
  		t.integer :new_user_id
  	end
  end
end
