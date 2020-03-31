class DropSfGuardUserPermissionTable < ActiveRecord::Migration[6.0]
  def up
  	drop_table :sf_guard_user_permission
  end

  def down
	  create_table :sf_guard_user_permission, id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
	    t.string "name"
	    t.text "description"
	    t.datetime "created_at"
	    t.datetime "updated_at"
	    t.index ["name"], name: "name", unique: true
	  end
  end
end
