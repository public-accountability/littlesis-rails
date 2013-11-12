class AddIndexToUsersSfGuardUserId < ActiveRecord::Migration
  def change
  	add_index :users, :sf_guard_user_id, unique: true
  end
end
