class AddReviewerIdToUserRequests < ActiveRecord::Migration
  def change
    add_column :user_requests, :reviewer_id, :integer, null: true
  end
end
