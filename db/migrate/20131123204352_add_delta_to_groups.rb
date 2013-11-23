class AddDeltaToGroups < ActiveRecord::Migration
  def change
  	change_table :groups do |t|
  		t.boolean :delta, default: true, null: false
  		t.index :delta
  	end
  end
end
