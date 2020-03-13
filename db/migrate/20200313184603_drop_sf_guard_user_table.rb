class DropSfGuardUserTable < ActiveRecord::Migration[6.0]
  def up
  	drop_table :sf_guard_user
  end

  def down
	  create_table :sf_guard_user, id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
	    t.string "username", limit: 128, null: false
	    t.string "algorithm", limit: 128, default: "sha1", null: false
	    t.string "salt", limit: 128
	    t.string "password", limit: 128
	    t.boolean "is_active", default: true
	    t.boolean "is_super_admin", default: false
	    t.datetime "last_login"
	    t.datetime "created_at"
	    t.datetime "updated_at"
	    t.boolean "is_deleted", default: false, null: false
	    t.index ["is_active"], name: "is_active_idx_idx"
	    t.index ["username"], name: "username", unique: true
	  end
  end
end
