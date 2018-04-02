class UpdateIntergerKeyLengthForAddress < ActiveRecord::Migration[5.1]
  def change
    remove_foreign_key :address, :sf_guard_user
    change_column :address, :last_user_id, :bigint
  end
end
