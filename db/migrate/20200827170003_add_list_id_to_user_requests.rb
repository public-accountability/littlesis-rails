class AddListIdToUserRequests < ActiveRecord::Migration[6.0]
  def change
    add_column :user_requests, :list_id, :integer
  end
end
