class AddGroupColumns < ActiveRecord::Migration
  def change
  	change_column :groups, :description, :text
  	change_table :groups do |t|
  		t.string :logo
  		t.text :findings
  		t.text :howto
  	end
  end
end
