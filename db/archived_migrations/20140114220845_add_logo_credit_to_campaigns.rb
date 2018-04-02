class AddLogoCreditToCampaigns < ActiveRecord::Migration
  def change
    change_table :campaigns do |t|
      t.string :logo_credit
    end
  end
end
