class AddGuardUserIdToUsers < ActiveRecord::Migration
  def change
  	change_table :users do |t|
  		t.integer :sf_guard_user_id, null: false
  	end
  end
end
