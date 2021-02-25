class RemoveUserNotNullConstraintOnUserRequests < ActiveRecord::Migration[6.1]
  def change
    execute "alter table user_requests alter column user_id drop not null"
  end
end
