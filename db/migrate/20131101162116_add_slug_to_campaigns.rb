class AddSlugToCampaigns < ActiveRecord::Migration
  def change
  	change_table :campaigns do |t|
  		t.string :slug
  		t.string :findings
  		t.string :howto
  	end
  end
end
