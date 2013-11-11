class AddCoverToGroups < ActiveRecord::Migration
  def change
  	change_table :groups do |t|
  		t.string :cover
  	end
  end
end
