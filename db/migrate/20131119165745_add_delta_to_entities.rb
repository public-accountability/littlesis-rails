class AddDeltaToEntities < ActiveRecord::Migration
  def change
  	change_table :entity do |t|
  		t.boolean :delta, default: true, null: false
  		t.index :delta
  	end
  end
end
