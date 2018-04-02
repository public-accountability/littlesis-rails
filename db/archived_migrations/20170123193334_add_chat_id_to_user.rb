class AddChatIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :chatid, :string
  end
end
