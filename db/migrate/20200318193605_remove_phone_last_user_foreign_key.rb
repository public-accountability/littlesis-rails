class RemovePhoneLastUserForeignKey < ActiveRecord::Migration[6.0]
  def change
  	remove_foreign_key :phone, :sf_guard_user
  end
end
