class RemoveListLastUserForeignKey < ActiveRecord::Migration[6.0]
  def change
  	remove_foreign_key :ls_list, :sf_guard_user
  end
end
