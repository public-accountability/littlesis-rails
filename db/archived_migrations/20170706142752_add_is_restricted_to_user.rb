class AddIsRestrictedToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_restricted, :boolean, :default => false
  end
end
