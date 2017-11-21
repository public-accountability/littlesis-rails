class ChangeUserAboutMeToText < ActiveRecord::Migration
  def change
	change_column :users, :about_me, :text
  end
end
