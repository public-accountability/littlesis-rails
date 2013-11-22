class AddDeltaToNote < ActiveRecord::Migration
  def change
  	change_table :note do |t|
  		t.boolean :delta, default: true, null: false
  		t.index :delta
  	end
  end
end