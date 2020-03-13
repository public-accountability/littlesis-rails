class RemoveTaggingLastUserForeignKey < ActiveRecord::Migration[6.0]
  def change
  	remove_foreign_key :tagging, :sf_guard_user
  end
end
