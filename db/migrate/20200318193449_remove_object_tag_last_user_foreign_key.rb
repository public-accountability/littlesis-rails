class RemoveObjectTagLastUserForeignKey < ActiveRecord::Migration[6.0]
  def change
  	remove_foreign_key :object_tag, :sf_guard_user
  end
end
