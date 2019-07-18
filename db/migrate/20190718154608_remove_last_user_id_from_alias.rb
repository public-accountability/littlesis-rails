class RemoveLastUserIdFromAlias < ActiveRecord::Migration[5.2]
  def change
    remove_column :alias, :last_user_id
  end
end
