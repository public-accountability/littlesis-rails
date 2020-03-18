class RemoveReferenceLastUserForeignKey < ActiveRecord::Migration[6.0]
  def change
  	remove_foreign_key :reference, :sf_guard_user
  end
end
