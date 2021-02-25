class AddEmailAndPageToUserRequest < ActiveRecord::Migration[6.1]
  def change
    add_column :user_requests, :email, :text
    add_column :user_requests, :page, :text
  end
end
