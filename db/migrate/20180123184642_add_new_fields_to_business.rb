class AddNewFieldsToBusiness < ActiveRecord::Migration[5.0]
  def change
    add_column :business, :assets, :bigint, :unsigned => true
    add_column :business, :marketcap, :bigint, :unsigned => true
    add_column :business, :net_income, :bigint, :unsigned => false
  end
end
