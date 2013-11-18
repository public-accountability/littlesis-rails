class AddSfGuardUserIdToNotes < ActiveRecord::Migration
  def change
  	change_table :note do |t|
  		t.references :sf_guard_user
  	end
  end
end
