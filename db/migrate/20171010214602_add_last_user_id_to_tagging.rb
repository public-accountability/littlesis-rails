class AddLastUserIdToTagging < ActiveRecord::Migration
  def change
    add_column :taggings, :last_user_id, :int, default: APP_CONFIG['system_user_id'], null: false
  end
end
