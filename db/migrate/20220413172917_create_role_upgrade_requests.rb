class CreateRoleUpgradeRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :role_upgrade_requests do |t|
      t.integer :role, null: false, limit: 1
      t.integer :status, null: false, default: 0, limit: 1
      t.bigint :user_id, null: false
      t.text :why
      t.timestamps
    end

    add_foreign_key :role_upgrade_requests, :users, column: 'user_id'
    add_index :role_upgrade_requests, :status
  end
end
