class DropIndustriesTable < ActiveRecord::Migration[6.1]
  def change
    drop_table :industries
    drop_table :business_industry
  end
end
