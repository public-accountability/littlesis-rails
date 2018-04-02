class AddFeaturedListToGroups < ActiveRecord::Migration
  def change
  	change_table :groups do |t|
  		t.references :featured_list
  	end
  end
end
