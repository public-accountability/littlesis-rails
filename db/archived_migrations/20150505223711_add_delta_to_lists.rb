class AddDeltaToLists < ActiveRecord::Migration
  def change
    change_table :ls_list do |t|
      t.boolean :delta, default: true, null: false
      t.index :delta
    end
  end
end
