class RemoveUserSfGuardUserForeignKey < ActiveRecord::Migration[6.0]
  def change
  	remove_foreign_key :users, :sf_guard_user
  end
end
