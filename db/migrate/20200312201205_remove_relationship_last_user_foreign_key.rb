class RemoveRelationshipLastUserForeignKey < ActiveRecord::Migration[6.0]
  def change
  	remove_foreign_key :relationship, :sf_guard_user
  end
end
