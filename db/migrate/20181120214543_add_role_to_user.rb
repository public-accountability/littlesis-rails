class AddRoleToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :role, :integer, limit: 1, default: 0, null: false
  end
end
