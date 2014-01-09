class ChangeGroupsIsPrivateDefault < ActiveRecord::Migration
  def up
  	change_column :groups, :is_private, :boolean, default: true, null: false
  end

  def down
  	change_column :groups, :is_private, :boolean, default: false, null: false
  end
end
