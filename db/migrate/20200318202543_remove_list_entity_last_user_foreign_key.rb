class RemoveListEntityLastUserForeignKey < ActiveRecord::Migration[6.0]
  def change
  	remove_foreign_key :ls_list_entity, :sf_guard_user
  end
end
