class RecreateRelationshipLastUserForeignKey < ActiveRecord::Migration[6.0]
  def change
  	add_foreign_key :relationship, :users, column: "last_user_id", on_update: :cascade
  end
end
