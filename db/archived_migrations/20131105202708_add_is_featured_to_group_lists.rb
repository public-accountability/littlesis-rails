class AddIsFeaturedToGroupLists < ActiveRecord::Migration
  def change
  	change_table :group_lists do |t|
  		t.boolean :is_featured, null: false, default: false
  	end
  end
end
