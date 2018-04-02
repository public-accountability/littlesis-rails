class AddCreatorUserIdToLists < ActiveRecord::Migration
  def change
  	add_column :ls_list, :creator_user_id, :integer
  end
end
