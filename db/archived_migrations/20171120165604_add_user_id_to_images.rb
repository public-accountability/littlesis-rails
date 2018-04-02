class AddUserIdToImages < ActiveRecord::Migration
  def change
  	add_column :image, :user_id, :integer
  end
end
