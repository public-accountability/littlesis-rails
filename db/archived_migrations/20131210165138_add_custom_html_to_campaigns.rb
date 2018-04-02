class AddCustomHtmlToCampaigns < ActiveRecord::Migration
  def change
  	change_table :campaigns do |t|
  		t.text :custom_html
  	end
  end
end
