class DropSfGuardPermissionTable < ActiveRecord::Migration[6.0]
	def up
		remove_foreign_key :sf_guard_user_permission, :sf_guard_user
		remove_foreign_key :sf_guard_user_permission, :sf_guard_permission
		drop_table :sf_guard_permission
	end

  def down
	  create_table :sf_guard_permission, id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
	    t.string "name"
	    t.text "description"
	    t.datetime "created_at"
	    t.datetime "updated_at"
	    t.index ["name"], name: "name", unique: true
	  end
  end
end
