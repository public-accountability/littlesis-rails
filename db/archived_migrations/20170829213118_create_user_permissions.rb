class CreateUserPermissions < ActiveRecord::Migration
  def change
    create_table :user_permissions do |t|
      t.references :user
      t.string :resource_type, null: false
      t.text :access_rules, limit: 16.megabytes - 1 # to accomodate json

      t.index [:user_id, :resource_type]
      t.timestamps null: false
    end
  end
end
