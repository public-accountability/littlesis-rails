class RemoveChatUser < ActiveRecord::Migration[6.0]
  def change
    drop_table :chat_user
  end
end
