class RemoveEmailLastUserForeignKey < ActiveRecord::Migration[6.0]
  def change
  	remove_foreign_key :email, :sf_guard_user
  end
end
