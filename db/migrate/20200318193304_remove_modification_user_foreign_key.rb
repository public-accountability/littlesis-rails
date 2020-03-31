class RemoveModificationUserForeignKey < ActiveRecord::Migration[6.0]
  def change
  	remove_foreign_key :modification, :sf_guard_user
  end
end
