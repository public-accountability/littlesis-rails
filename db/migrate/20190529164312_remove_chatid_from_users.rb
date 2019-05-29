class RemoveChatidFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :chatid
  end
end
