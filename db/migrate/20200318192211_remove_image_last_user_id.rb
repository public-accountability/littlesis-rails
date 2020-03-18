class RemoveImageLastUserId < ActiveRecord::Migration[6.0]
  def change
  	remove_foreign_key :image, :sf_guard_user
  	remove_column :image, :last_user_id, :image
  end
end
