class ReplaceIsPrivateWithAccessOnLists < ActiveRecord::Migration
  def self.up
    List.where(is_private: true).update_all(access: List::ACCESS_PRIVATE)
    remove_column :ls_list, :is_private
  end

  def self.down
    add_column :ls_list, :is_private, :boolean, default: false
    List.where(access: List::ACCESS_PRIVATE).update_all(is_private: true)
  end
end
