class RecreateEntityLastUserForeignKey < ActiveRecord::Migration[6.0]
  def change
  	add_foreign_key :entity, :users, column: "last_user_id", on_update: :cascade
  end
end
