class DropSessionsTable < ActiveRecord::Migration[6.0]
  def change
    drop_table :sessions do |t|
      t.string "session_id", null: false
      t.text "data", size: :long
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
      t.index ["updated_at"], name: "index_sessions_on_updated_at"
    end
  end
end
