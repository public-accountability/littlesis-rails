class AddEntityIdToUserRequests < ActiveRecord::Migration
  def change
    add_column :user_requests, :entity_id, :integer, null: true
  end
end
