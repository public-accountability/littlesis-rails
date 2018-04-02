class ChangeGroupsIsPrivate < ActiveRecord::Migration
  def change
  	change_column :groups, :is_private, :boolean, { default: true, null: false }
  end
end
