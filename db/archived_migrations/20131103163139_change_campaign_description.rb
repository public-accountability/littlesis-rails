class ChangeCampaignDescription < ActiveRecord::Migration
  def change
  	change_column :campaigns, :description, :text
  	change_column :campaigns, :findings, :text
  	change_column :campaigns, :howto, :text
  end
end
