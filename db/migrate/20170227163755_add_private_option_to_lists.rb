class AddPrivateOptionToLists < ActiveRecord::Migration
  def change
  	add_column :ls_list, :is_private, :boolean, default: false
  end
end
