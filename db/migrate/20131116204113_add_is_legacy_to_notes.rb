class AddIsLegacyToNotes < ActiveRecord::Migration
  def change
  	change_table :note do |t|
  		t.boolean :is_legacy, null: false, default: false
  	end
  end
end
