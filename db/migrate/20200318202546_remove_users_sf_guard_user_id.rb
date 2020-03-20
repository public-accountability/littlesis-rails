class RemoveUsersSfGuardUserId < ActiveRecord::Migration[6.0]
  def change
  	remove_column :users, :sf_guard_user_id, :integer
  en
end
