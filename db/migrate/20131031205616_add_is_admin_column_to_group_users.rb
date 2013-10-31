class AddIsAdminColumnToGroupUsers < ActiveRecord::Migration
  def change
  	change_table :group_users do |t|
  		t.boolean :is_admin, null: false, default: false
  	end
  end
end
