class AddJustificationToUserRequest < ActiveRecord::Migration[5.0]
  def up
    add_column :user_requests, :justification, :text
    UserRequest.update_all justification: "This request was made before justifications were added"
  end
  
  def down
    remove_column :user_requests, :justification
  end
end
