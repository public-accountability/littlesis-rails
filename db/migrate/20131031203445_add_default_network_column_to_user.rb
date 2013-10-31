class AddDefaultNetworkColumnToUser < ActiveRecord::Migration
  def change
  	change_table :users do |t|
  		t.references :default_network
  	end
  end
end
