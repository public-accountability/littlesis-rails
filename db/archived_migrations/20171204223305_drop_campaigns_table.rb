class DropCampaignsTable < ActiveRecord::Migration
  def change
    drop_table :campaigns
  end
end
